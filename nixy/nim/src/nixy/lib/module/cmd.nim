import ../config
import ../errors
import ../path
import cmd_python
import types

import os
import osproc
import strutils


proc prepareCommand*(command: string = "",
                     nixUserChrootDir: string = defaultNixUserChrootDir,
                     nixDir: string = defaultNixDir,
                     sourceNixProfileSh: bool = true,
                     fixLocale: bool = true,
                     useSystemLocaleArchive: bool = false,
                     sourceNixyProfile: bool = true,
                     modules: seq[Module] = @[Module.Python]): string =
  let nixUserChrootPath = getNixUserChrootPath(nixUserChrootDir)
  let nixDir = nixDir.expandTilde
  let execBash = quoteShellCommand([nixUserChrootPath, nixDir, "bash"])
  var command = command
  if isEmptyOrWhitespace(command):
    command = "bash"
  if Module.Python in modules:
    let prefix = getCommandPrefixForCurrentDirForPython()
    if not isEmptyOrWhitespace(prefix):
      command = prefix & "; " & command
  if sourceNixyProfile:
    let nixyProfileFile = getNixyProfileFile()
    if not isEmptyOrWhitespace(nixyProfileFile):
      if areNixyDirConfigsAllowed(nixyProfileFile.parentDir):
        command = "source " & quoteShell(nixyProfileFile) & "; " & command
      else:
        echo("Nixy profile found, but it's not allowed in the Nixy configuration file; Use nixy nixy_allow_profile")
  if sourceNixProfileSh:
    command = "source " & quoteShell(nixProfileSh) & "; " & command
  if fixLocale:
    if not useSystemLocaleArchive:
      let nixLocale = "~/.nix-profile".expandTilde.expandSymlink
      let nixLocaleArchive = nixLocale / "lib" / "locale" / "locale-archive"
      command = "export LOCALE_ARCHIVE=" & quoteShell(nixLocaleArchive) & "; " & command
    else:
      if systemLocaleArchive.fileExists:
        command = "export LOCALE_ARCHIVE=" & quoteShell(systemLocaleArchive) & "; " & command
      else:
        raise newException(LocaleArchiveNotFoundError,
                           "No locale archive found, please install it using:\n" &
                           "nixy install --attr nixpkgs.glibcLocales")
  return execBash & " -c '" & command & "'"

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
