import ../lib/errors
import ../lib/module/pkg
import ../lib/path

import options
import strutils
import system


proc install*(package: seq[string],
              unstable: bool = false,
              attr: bool = false,
              nix_user_chroot_url: string = "",
              nix_user_chroot_version: string = nixUserChrootLatestVersion,
              nix_user_chroot_dir: string = defaultNixUserChrootDir,
              nix_dir = defaultNixDir): int
             {.raises: [].} =
  proc toOption(s: string): Option[string] =
    if not isEmptyOrWhitespace(s):
      some(s)
    else:
      none(string)

  try:
    let nixUserChrootURL = toOption(nixUserChrootURL)
    bootstrap(url = nixUserChrootURL,
              version = nixUserChrootVersion,
              nixUserChrootDir = nixUserChrootDir,
              nixDir = nixDir)
    pkg.install(packages = package,
                unstable = unstable,
                attr = attr,
                nixUserChrootDir = nixUserChrootDir,
                nixDir = nixDir)
  except BootstrapError, InstallError:
    echo(getCurrentExceptionMsg())
    return 1
  return 0

proc remove*(package: seq[string],
             nix_user_chroot_dir: string = defaultNixUserChrootDir,
             nix_dir = defaultNixDir): int
            {.raises: [].} =
  try:
    pkg.remove(packages = package, nixUserChrootDir = nixUserChrootDir, nixDir = nixDir)
  except RemoveError as e:
    echo(e.msg)
    return 1
  return 0

proc list*(available: bool = false,
           nix_user_chroot_dir: string = defaultNixUserChrootDir,
           nix_dir = defaultNixDir): int
          {.raises: [].} =
  try:
    pkg.query(available = available, nixUserChrootDir = nixUserChrootDir, nixDir = nixDir)
  except QueryError as e:
    echo(e.msg)
    return 1
  return 0
