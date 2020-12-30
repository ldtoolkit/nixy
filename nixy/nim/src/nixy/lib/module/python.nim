import ../config
import ../errors
import ../path
import cmd
import nixy
import python_utils

import os
import strutils


proc venv*(name: string = "",
           venvDir: string = "",
           pythonExecutable: string = defaultPythonExecutable,
           nixUserChrootDir: string = defaultNixUserChrootDir,
           nixDir: string = defaultNixDir,
           useSystemLocaleArchive: bool = false)
          {.raises: [PythonVenvCreationError].} =
  const errorMessage = "Failed to create venv: "
  if isEmptyOrWhitespace(name) and isEmptyOrWhitespace(venvDir):
    raise newException(PythonVenvCreationError, errorMessage & "both (name and venv dir) cannot be empty")

  try:
    let venvDir = if not isEmptyOrWhitespace(name): getPythonVenvDir(name) else: venvDir
    let command = pythonExecutable & " -m venv " & quoteShell(venvDir)
    run(command)
  except PythonVenvGetDirError, RunError:
    raise newException(PythonVenvCreationError, errorMessage & getCurrentExceptionMsg())

proc local*(name: string = "", venvDir: string = "") {.raises: [ConfigError, PythonVenvLocalError].} =
  const errorMessage = "Failed to write Nixy Python version to .nixy-python-version: "

  if isEmptyOrWhitespace(name) and isEmptyOrWhitespace(venvDir):
    raise newException(PythonVenvLocalError, errorMessage & "both (name and venv dir) cannot be empty")

  try:
    writeFile(getCurrentDir() / nixyPythonVersionFileName, if not isEmptyOrWhitespace(name): name else: venvDir)
  except IOError, OSError:
    raise newException(PythonVenvLocalError, errorMessage & getCurrentExceptionMsg())
  allowCurrentDirNixyConfigs()

proc which*: string {.raises: PythonVenvGetLocalError.} =
  getLocalVenv()