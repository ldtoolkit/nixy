import config
import errors

import distros
import httpclient
import options
import os
import osproc
import sequtils
import sets
import strformat
import strutils
import system


const nixUserChrootLatestVersion* = "1.0.3"
const defaultNixUserChrootDir* = "~/.nix-user-chroot/"
const defaultNixDir* = "~/.nix/"
const nixProfileSh = "~/.nix-profile/etc/profile.d/nix.sh"
const systemLocaleArchive = "/usr/lib/locale/locale-archive"


template suppress*(body: untyped) =
  try:
    body
  except:
    discard

proc raiseOnIncompatabileOS {.raises: [IncompatibleOSError].} =
  try:
    if not detectOs(Linux):
      raise newException(IncompatibleOSError,
          $IncompatibleOSErrorMessage.NotGNULinux)
  except Exception:
    raise newException(IncompatibleOSError,
        $IncompatibleOSErrorMessage.NotGNULinux)
  if not (hostCPU == "amd64" or hostCPU == "i386"):
    raise newException(IncompatibleOSError,
        $IncompatibleOSErrorMessage.NotAmd64OrI386)
  const checkUserNamespacesArgs = ["--user", "--pid", "echo", "YES"]
  let namespacesForUnprivelegedUsersString =
    try:
      execProcess("unshare", args = checkUserNamespacesArgs, options = {poUsePath})
    except Exception:
      "NO"
  if namespacesForUnprivelegedUsersString.strip != "YES":
    raise newException(IncompatibleOSError,
        $IncompatibleOSErrorMessage.UnsupportedUserNamespaces)

proc getNixUserChrootPath*(nixUserChrootDir: string): string {.raises: [].} =
  nixUserChrootDir.expandTilde / "nix-user-chroot"

proc downloadNixUserChroot(url: Option[string] = none(string),
                           version: string = nixUserChrootLatestVersion,
                           outputDir: string = "/tmp/"): string
                          {.raises: [DownloadError, IncompatibleOSError, IOError, OSError].} =
  proc getUrl: string =
    proc getPlatform: string =
      if hostCPU == "amd64":
        "x86_64"
      elif hostCPU == "i386":
        "i686"
      else:
        raise newException(IncompatibleOSError,
            $IncompatibleOSErrorMessage.NotAmd64OrI386)

    if isNone(url):
      let platform = getPlatform()
      const releasesURL = "https://github.com/nix-community/nix-user-chroot/releases/download"
      suppress:
        return fmt"{releasesURL}/{version}/nix-user-chroot-bin-{version}-{platform}-unknown-linux-musl"
    else:
      return url.get

  let outputDir = outputDir.expandTilde

  proc getPath: string =
    outputDir / "nix-user-chroot"

  discard outputDir.existsOrCreateDir
  let path = getPath()
  let url = getUrl()

  if not path.fileExists:
    suppress: echo(fmt"Downloading nix-user-chroot from {url} to '{path}'")
    try:
      let client = newHttpClient()
      client.downloadFile(url = url, filename = path)
    except Exception as e:
      raise newException(DownloadError, "Failed to download nix-user-chroot: " & e.msg)

  path.setFilePermissions({fpUserExec, fpUserWrite, fpUserRead})

  path


proc getNixyProfileFile*: string = getCurrentDir() / ".nixyrc"


proc prepareCommand*(command: string = "",
                     nixUserChrootDir: string = defaultNixUserChrootDir,
                     nixDir: string = defaultNixDir,
                     sourceNixProfileSh: bool = true,
                     fixLocale: bool = true,
                     useSystemLocaleArchive: bool = false,
                     sourceNixyProfile: bool = true): string =
  let nixUserChrootPath = getNixUserChrootPath(nixUserChrootDir)
  let nixDir = nixDir.expandTilde
  suppress:
    let execBash = fmt"{nixUserChrootPath} {nixDir} bash"
    var command = command
    if isEmptyOrWhitespace(command):
      command = "bash"
    if sourceNixyProfile and getNixyProfileFile().fileExists:
      if isCurrentDirNixyProfileAllowed():
        command = fmt"source {getNixyProfileFile()}; {command}"
      else:
        echo("Nixy profile found in current dir, but it's not allowed in the Nixy configuration file; " &
             "Use nixy nixy_allow_profile")
    if sourceNixProfileSh:
      command = fmt"source {nixProfileSh}; {command}"
    if fixLocale:
      let nixLocale = "~/.nix-profile".expandTilde.expandSymlink
      if not useSystemLocaleArchive:
        let nixLocaleArchive = nixLocale / "lib" / "locale" / "locale-archive"
        command = fmt"export LOCALE_ARCHIVE={nixLocaleArchive}; {command}"
      else:
        if systemLocaleArchive.fileExists:
          command = fmt"export LOCALE_ARCHIVE={systemLocaleArchive}; {command}"
        else:
          raise newException(LocaleArchiveNotFoundError,
                             "No locale archive found, please install it using:\n" &
                             "nixy install --attr nixpkgs.glibcLocales")
    return fmt"{execBash} -c '{command}'"

proc install*(packages: seq[string],
              unstable: bool = false,
              attr: bool = false,
              nixUserChrootDir: string = defaultNixUserChrootDir,
              nixDir: string = defaultNixDir)
             {.raises: [InstallError].} =
  let nixDir = nixDir.expandTilde
  if unstable:
    echo("Adding unstable channel")
    const addUnstableChannelCommand = "nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable"
    const updateChannelsCommand = "nix-channel --update"
    try:
      let command = prepareCommand(fmt"{addUnstableChannelCommand}; {updateChannelsCommand}",
                                   nixUserChrootDir = nixUserChrootDir,
                                   nixDir = nixDir)
      execProcess(command)
    except Exception as e:
      raise newException(InstallError, "Failed to add unstable channel: " & e.msg)
  for package in packages:
    proc getPackage(package: string): string =
      suppress:
        if unstable:
          return fmt"nixos-unstable.{package}"
        else:
          return package

    let package = getPackage(package)
    suppress: echo(fmt"Installing {package}")
    let installationOutput =
      try:
        let attrFlag = if unstable or attr: "--attr" else: ""
        let command = prepareCommand(fmt"nix-env --install {attrFlag} {package}",
                                     nixUserChrootDir = nixUserChrootDir,
                                     nixDir = nixDir)
        execProcess(command)
      except Exception as e:
        raise newException(InstallError, "Failed to install package '" & package & "': " & e.msg)
    if "error: selector '" & package & "' matches no derivations" in installationOutput:
      raise newException(InstallError, "Failed to install package '" & package & "': No packages found")
    suppress: echo(fmt"{package} installation finished")

proc remove*(packages: seq[string],
             nixUserChrootDir: string = defaultNixUserChrootDir,
             nixDir: string = defaultNixDir)
            {.raises: [RemoveError].} =
  let nixDir = nixDir.expandTilde
  for package in packages:
    suppress: echo(fmt"Removing {package}")
    try:
      let command = prepareCommand(fmt"nix-env --uninstall {package}; nix-collect-garbage",
                                   nixUserChrootDir = nixUserChrootDir,
                                   nixDir = nixDir)
      execProcess(command)
    except Exception as e:
      raise newException(RemoveError, "Failed to remove package '" & package & "': " & e.msg)
    suppress: echo(fmt"{package} removed")

proc query*(available: bool = false,
            nixUserChrootDir: string = defaultNixUserChrootDir,
            nixDir: string = defaultNixDir)
           {.raises: [QueryError].} =
  let nixDir = nixDir.expandTilde
  let output =
    try:
      let flag = if available: "--available" else: "--installed"
      let command = prepareCommand(fmt"nix-env --query {flag}", nixUserChrootDir = nixUserChrootDir, nixDir = nixDir)
      execProcess(command)
    except Exception as e:
      raise newException(QueryError, "Failed to query packages: " & e.msg)
  let lines = output.strip.splitLines
  for line in lines.toSeq.toOrderedSet:
    echo(line)

proc bootstrap*(url: Option[string] = none(string),
                version: string = nixUserChrootLatestVersion,
                nixUserChrootDir: string = defaultNixUserChrootDir,
                nixDir: string = defaultNixDir)
               {.raises: [BootstrapError].} =
  const bootstrapErrorMessage = "Failed to bootstrap Nix: "

  try:
    raiseOnIncompatabileOS()
    discard downloadNixUserChroot(url = url, version = version, outputDir = nixUserChrootDir)
    let nixDir = nixDir.expandTilde
    let nixDirExists = nixDir.existsOrCreateDir
    if nixDirExists:
      return
    echo("Bootstrapping Nix (this may take a minute or two)")
    let installationOutput =
      try:
        const installNixCommand = "curl -L https://nixos.org/nix/install | sh"
        let command = prepareCommand(installNixCommand,
                                     nixUserChrootDir = nixUserChrootDir,
                                     nixDir = nixDir,
                                     sourceNixProfileSh = false,
                                     fixLocale = false)
        execProcess(command)
      except Exception as e:
        raise newException(BootstrapError, bootstrapErrorMessage & e.msg)
    if "Installation finished!" in installationOutput:
      echo("Nix bootstrap finished")
    else:
      raise newException(BootstrapError, bootstrapErrorMessage & "Bootstrap output: " & installationOutput)
  except DownloadError, IncompatibleOSError, OSError, IOError:
    raise newException(BootstrapError, bootstrapErrorMessage & getCurrentExceptionMsg())
  if not systemLocaleArchive.fileExists:
    echo("System locale archive not found")
    try:
      install(@["nixpkgs.glibcLocales"],
              unstable = false,
              attr = true,
              nixUserChrootDir = nixUserChrootDir,
              nixDir = nixDir)
    except InstallError as e:
      raise newException(BootstrapError, bootstrapErrorMessage & e.msg)

proc run*(command: string,
          nixUserChrootDir: string = defaultNixUserChrootDir,
          nixDir: string = defaultNixDir,
          useSystemLocaleArchive: bool = false)
         {.raises: [RunError].} =
  let nixDir = nixDir.expandTilde
  try:
    let command = prepareCommand(command,
                                 nixUserChrootDir = nixUserChrootDir,
                                 nixDir = nixDir,
                                 useSystemLocaleArchive = useSystemLocaleArchive)
    execCmd(command)
  except Exception as e:
    raise newException(RunError, "Failed to run command '" & command & "': " & e.msg)
