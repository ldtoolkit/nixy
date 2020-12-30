import ../lib/errors
import ../lib/module/cmd
import ../lib/path

import os


proc run*(command: seq[string],
          nix_user_chroot_dir: string = defaultNixUserChrootDir,
          nix_dir = defaultNixDir,
          use_system_locale_archive: bool = false): int
         {.raises: [].} =
  try:
    cmd.run(command = quoteShellCommand(command),
            nixUserChrootDir = nixUserChrootDir,
            nixDir = nixDir,
            useSystemLocaleArchive = useSystemLocaleArchive)
  except RunError as e:
    echo(e.msg)
    return 1
  return 0
