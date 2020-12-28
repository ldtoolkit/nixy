import config
import core
import errors
import nixy
import store

import os
import strutils


const defaultPythonExecutable* = "python";


type
  PythonVenvCreationError* = object of NixyError
  PythonVenvLocalError* = object of NixyError


proc getPythonStoreDir: string {.raises: [StoreDirError].} = getStoreDir("python")

proc getPythonVenvDir(name: string): string {.raises: [StoreDirError].} =
  result = getPythonStoreDir() / "venv" / name
  try:
    result.createDir
  except IOError, OSError:
    raise newException(StoreDirError, "Failed to get venv dir " & quoteShell(result) & ": " & getCurrentExceptionMsg())

proc venv*(name: string = "",
           venvDir: string = "",
           pythonExecutable: string = defaultPythonExecutable,
           nixUserChrootDir: string = defaultNixUserChrootDir,
           nixDir: string = defaultNixDir,
           useSystemLocaleArchive: bool = false)
          {.raises: [PythonVenvCreationError].} =
  const PythonVenvCreationErrorMessage = "Failed to create venv: "
  if isEmptyOrWhitespace(name) and isEmptyOrWhitespace(venvDir):
    raise newException(PythonVenvCreationError,
                       PythonVenvCreationErrorMessage & "both (name and venv dir) cannot be empty")

  try:
    let venvDir = if not isEmptyOrWhitespace(name): getPythonVenvDir(name) else: venvDir
    let command = pythonExecutable & " -m venv " & quoteShell(venvDir)
    run(command)
  except RunError, StoreDirError:
    raise newException(PythonVenvCreationError, PythonVenvCreationErrorMessage & getCurrentExceptionMsg())

proc local*(name: string = "", venvDir: string = "") {.raises: [ConfigError, PythonVenvLocalError].} =
  const PythonVenvLocalErrorMessage = "Failed to write venv activation command to .nixyrc: "
  if isEmptyOrWhitespace(name) and isEmptyOrWhitespace(venvDir):
    raise newException(PythonVenvLocalError, PythonVenvLocalErrorMessage & "both (name and venv dir) cannot be empty")

  try:
    let nixyProfileFileContent = readFile(getNixyProfileFile())
    let venvDir = if not isEmptyOrWhitespace(name): getPythonVenvDir(name) else: venvDir
    let activateFile = venvDir / "bin" / "activate"
    let venvActivationCommand = "source " & quoteShell(activateFile)
    if not (venvActivationCommand in nixyProfileFileContent.splitLines()):
      let f = open(getNixyProfileFile(), fmAppend)
      defer: f.close()
      f.write(venvActivationCommand)
  except IOError, OSError, StoreDirError:
    raise newException(PythonVenvLocalError, PythonVenvLocalErrorMessage & getCurrentExceptionMsg())
  allowCurrentDirNixyProfile()
