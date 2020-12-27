import config
import core
import errors
import nixy

import os
import strformat
import strutils


const defaultPythonExecutable* = "python";


type
  PythonVenvLocal* = object of NixyError


proc venv*(venvDir: string,
           pythonExecutable: string = defaultPythonExecutable,
           nixUserChrootDir: string = defaultNixUserChrootDir,
           nixDir: string = defaultNixDir,
           useSystemLocaleArchive: bool = false)
          {.raises: [RunError].} =
  var command: string
  suppress: command = fmt"{pythonExecutable} -m venv {venvDir}"
  run(command)

proc local*(venvDir: string) {.raises: [ConfigError, PythonVenvLocal].} =
  try:
    let nixyProfileFileContent = readFile(getNixyProfileFile())
    let activateFile = venvDir / "bin" / "activate"
    let venvActivationCommand = "source " & quoteShell(activateFile)
    if not (venvActivationCommand in nixyProfileFileContent.splitLines()):
      let f = open(getNixyProfileFile(), fmAppend)
      defer: f.close()
      f.write(venvActivationCommand)
  except IOError, OSError:
    raise newException(PythonVenvLocal,
                       "Failed to write venv activation command to .nixyrc: " & getCurrentExceptionMsg())
  allowCurrentDirNixyProfile()