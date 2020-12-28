import config
import core
import errors
import nixy
import store

import os
import strutils


const defaultPythonExecutable* = "python";


type
  PythonVenvError* = object of NixyError
  PythonVenvCreationError* = object of PythonVenvError
  PythonVenvLocalError* = object of PythonVenvError


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
  const errorMessage = "Failed to create venv: "
  if isEmptyOrWhitespace(name) and isEmptyOrWhitespace(venvDir):
    raise newException(PythonVenvCreationError, errorMessage & "both (name and venv dir) cannot be empty")

  try:
    let venvDir = if not isEmptyOrWhitespace(name): getPythonVenvDir(name) else: venvDir
    let command = pythonExecutable & " -m venv " & quoteShell(venvDir)
    run(command)
  except RunError, StoreDirError:
    raise newException(PythonVenvCreationError, errorMessage & getCurrentExceptionMsg())

proc getVenvActivationCommand(name: string = "", venvDir: string = ""): string {.raises: [PythonVenvError].} =
  const errorMessage = "Failed to prepare venv activation command: "
  if isEmptyOrWhitespace(name) and isEmptyOrWhitespace(venvDir):
    raise newException(PythonVenvError, errorMessage & "both (name and venv dir) cannot be empty")

  let venvDir =
    try:
      if not isEmptyOrWhitespace(name): getPythonVenvDir(name) else: venvDir
    except StoreDirError as e:
      raise newException(PythonVenvError, errorMessage & e.msg)
  let activateFile = venvDir / "bin" / "activate"
  "source " & quoteShell(activateFile)

proc local*(name: string = "", venvDir: string = "") {.raises: [ConfigError, PythonVenvLocalError].} =
  const errorMessage = "Failed to write venv activation command to .nixyrc: "
  try:
    let nixyProfileFile = getNixyProfileFile()
    let nixyProfileFileContent = if nixyProfileFile.fileExists: readFile(nixyProfileFile) else: ""
    let venvActivationCommand = getVenvActivationCommand(name = name, venvDir = venvDir)
    if not (venvActivationCommand in nixyProfileFileContent.splitLines()):
      let f = open(nixyProfileFile, fmAppend)
      defer: f.close()
      f.write(venvActivationCommand)
  except IOError, OSError, PythonVenvError, StoreDirError:
    raise newException(PythonVenvLocalError, errorMessage & getCurrentExceptionMsg())
  allowCurrentDirNixyProfile()
