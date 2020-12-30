import ../lib/errors
import ../lib/module/postgresql
import ../lib/path

import os


proc postgresql_init*(store_dir: string = defaultPostgreSQLStoreDir,
                      nix_user_chroot_dir: string = defaultNixUserChrootDir,
                      nix_dir: string = defaultNixDir,
                      use_system_locale_archive: bool = false): int
                     {.raises: [].} =
  try:
    postgresql.init(storeDir = store_dir,
                    nixUserChrootDir = nixUserChrootDir,
                    nixDir = nixDir,
                    useSystemLocaleArchive = useSystemLocaleArchive)
  except RunError as e:
    echo(e.msg)
    return 1
  return 0

proc postgresql_start*(store_dir: seq[string] = @[defaultPostgreSQLStoreDir],
                       log_file: string = defaultPostgreSQLLogFile,
                       socket_dir: string = defaultPostgreSQLSocketDir,
                       nix_user_chroot_dir: string = defaultNixUserChrootDir,
                       nix_dir: string = defaultNixDir,
                       use_system_locale_archive: bool = false): int
                      {.raises: [].} =
  try:
    postgresql.pgCtl("start",
                     storeDir=store_dir[0],
                     logFile = logFile,
                     socketDir = socketDir,
                     nixUserChrootDir = nixUserChrootDir,
                     nixDir = nixDir,
                     useSystemLocaleArchive = useSystemLocaleArchive)
  except RunError as e:
    echo(e.msg)
    return 1
  return 0

proc postgresql_stop*(store_dir: string = defaultPostgreSQLStoreDir,
                      log_file: string = defaultPostgreSQLLogFile,
                      socket_dir: string = defaultPostgreSQLSocketDir,
                      nix_user_chroot_dir: string = defaultNixUserChrootDir,
                      nix_dir: string = defaultNixDir,
                      use_system_locale_archive: bool = false): int
                     {.raises: [].} =
  try:
    postgresql.pgCtl("stop",
                     storeDir = store_dir,
                     logFile = logFile,
                     socketDir = socketDir,
                     nixUserChrootDir = nixUserChrootDir,
                     nixDir = nixDir,
                     useSystemLocaleArchive = useSystemLocaleArchive)
  except RunError as e:
    echo(e.msg)
    return 1
  return 0

proc postgresql_manage*(command: seq[string],
                        store_dir: string = defaultPostgreSQLStoreDir,
                        log_file: string = defaultPostgreSQLLogFile,
                        socket_dir: string = defaultPostgreSQLSocketDir,
                        nix_user_chroot_dir: string = defaultNixUserChrootDir,
                        nix_dir: string = defaultNixDir,
                        use_system_locale_archive: bool = false): int
                       {.raises: [].} =
  try:
    postgresql.manage(quoteShellCommand(command),
                      storeDir = store_dir,
                      logFile = logFile,
                      socketDir = socketDir,
                      nixUserChrootDir = nixUserChrootDir,
                      nixDir = nixDir,
                      useSystemLocaleArchive = useSystemLocaleArchive)
  except RunError as e:
    echo(e.msg)
    return 1
  return 0
