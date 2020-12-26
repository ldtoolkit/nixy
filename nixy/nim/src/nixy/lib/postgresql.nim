import core
import os
import osproc
import strformat
import strutils


const defaultPostgreSQLLogFile* = "~/.postgresql/postgresql.log"
const defaultPostgreSQLSocketDir* = "~/.postgresql/"
const defaultPostgreSQLStoreDir* = "~/.postgresql/"


proc init*(storeDir: string = defaultPostgreSQLStoreDir,
           nixUserChrootDir: string = defaultNixUserChrootDir,
           nixDir: string = defaultNixDir,
           useSystemLocaleArchive: bool = false)
          {.raises: [RunError].} =
  let nixDir = nixDir.expandTilde
  const errorMessage = "Failed to init PostgreSQL cluster"
  let output =
    try:
      let command = prepareCommand(fmt"initdb -D {storeDir}",
                                   nixUserChrootDir = nixUserChrootDir,
                                   nixDir = nixDir,
                                   useSystemLocaleArchive = useSystemLocaleArchive)
      execProcess(command)
    except Exception as e:
      raise newException(RunError, errorMessage & ": " & e.msg)
  if not ("Success. You can now start the database server using:" in output):
      raise newException(RunError, errorMessage & ":\n" & output)

proc preparePgCtlCommand(command: string,
                         storeDir: string = defaultPostgreSQLStoreDir,
                         logFile: string = defaultPostgreSQLLogFile,
                         socketDir: string = defaultPostgreSQLSocketDir): string =
  let socketDir = socketDir.expandTilde
  suppress: return fmt"pg_ctl -D {storeDir} -l {logFile} -o '--unix_socket_directories={socketDir}' {command}"

proc pgCtl*(command: string,
            storeDir: string = defaultPostgreSQLStoreDir,
            logFile: string = defaultPostgreSQLLogFile,
            socketDir: string = defaultPostgreSQLSocketDir,
            nixUserChrootDir: string = defaultNixUserChrootDir,
            nixDir: string = defaultNixDir,
            useSystemLocaleArchive: bool = false)
           {.raises: [RunError].} =
  let nixDir = nixDir.expandTilde
  try:
    let pgCtlCommand = preparePgCtlCommand(command, storeDir = storeDir, logFile = logFile, socketDir = socketDir)
    let command = prepareCommand(pgCtlCommand,
                                 nixUserChrootDir = nixUserChrootDir,
                                 nixDir = nixDir,
                                 useSystemLocaleArchive = useSystemLocaleArchive)
    execCmd(command)
  except Exception as e:
    raise newException(RunError, "Failed to start PostgreSQL cluster: " & e.msg)

proc manage*(command: string,
             storeDir: string = defaultPostgreSQLStoreDir,
             logFile: string = defaultPostgreSQLLogFile,
             socketDir: string = defaultPostgreSQLSocketDir,
             nixUserChrootDir: string = defaultNixUserChrootDir,
             nixDir: string = defaultNixDir,
             useSystemLocaleArchive: bool = false)
            {.raises: [RunError].} =
  let nixDir = nixDir.expandTilde
  const errorMessage = "Failed to manage PostgreSQL"
  try:
    let startCommand = preparePgCtlCommand("start", storeDir = storeDir, logFile = logFile, socketDir = socketDir)
    let stopCommand = preparePgCtlCommand("stop", storeDir = storeDir, logFile = logFile, socketDir = socketDir)
    var command = fmt"{stopCommand} >/dev/null 2>/dev/null; {startCommand} >/dev/null 2>/dev/null; {command}"
    command = prepareCommand(command,
                             nixUserChrootDir = nixUserChrootDir,
                             nixDir = nixDir,
                             useSystemLocaleArchive = useSystemLocaleArchive)
    execCmd(command)
  except Exception as e:
    raise newException(RunError, errorMessage & ": " & e.msg)
