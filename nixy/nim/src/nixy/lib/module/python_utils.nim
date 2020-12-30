import ../config
import ../errors
import ../store
import ../path

import os
import strutils


const defaultPythonExecutable* = "python";
const nixyPythonVersionFileName* = ".nixy-python-version";
const venvActivationCommandPreparationErrorMessage* = "Failed to prepare Python venv activation command: "


type
  PythonVenvError* = object of NixyError
  PythonVenvCreationError* = object of PythonVenvError
  PythonVenvLocalError* = object of PythonVenvError
  PythonVenvGetDirError* = object of PythonVenvError
  PythonVenvGetLocalError* = object of PythonVenvError


proc getPythonStoreDir: string {.raises: [StoreDirError].} = getStoreDir("python")

proc getPythonVenvDir*(name: string, create: bool = true): string {.raises: [PythonVenvGetDirError].} =
  try:
    result = getPythonStoreDir() / "venv" / name
  except StoreDirError as e:
    raise newException(PythonVenvGetDirError, "Failed to get venv dir: Failed to get Python store dir: " & e.msg)
  let errorMessage = "Failed to get venv dir " & quoteShell(result) & ": "
  if create:
    try:
      result.createDir
    except IOError, OSError:
      raise newException(PythonVenvGetDirError, errorMessage & getCurrentExceptionMsg())
  else:
    if result.dirExists:
      result
    else:
      raise newException(PythonVenvGetDirError, errorMessage & "Dir does not exist")

proc getNixyPythonVersionFile*: string {.raises: [].} = findFileInCurrentDirOrParents(nixyPythonVersionFileName)

proc getVenvActivationCommand*(name: string = "", venvDir: string = ""): string {.raises: [PythonVenvError].} =
  if isEmptyOrWhitespace(name) and isEmptyOrWhitespace(venvDir):
    raise newException(PythonVenvError,
                       venvActivationCommandPreparationErrorMessage & "both (name and venv dir) cannot be empty")

  let venvDir =
    try:
      if not isEmptyOrWhitespace(name): getPythonVenvDir(name) else: venvDir
    except PythonVenvGetDirError as e:
      raise newException(PythonVenvError, venvActivationCommandPreparationErrorMessage & e.msg)
  let activateFile = venvDir / "bin" / "activate"
  "source " & quoteShell(activateFile)

proc getLocalVenv*: string {.raises: [PythonVenvGetLocalError].} =
  const errorMessage = "Failed to get Python local venv: "
  let nixyPythonVersionFile = getNixyPythonVersionFile()
  if not isEmptyOrWhitespace(nixyPythonVersionFile):
    let dirConfigsAllowed =
      try:
        areNixyDirConfigsAllowed(nixyPythonVersionFile.parentDir)
      except ConfigReadError as e:
        raise newException(PythonVenvGetLocalError, errorMessage & e.msg)
    if dirConfigsAllowed:
      try:
        return readFile(nixyPythonVersionFile).strip.expandTilde
      except IOError as e:
        raise newException(PythonVenvGetLocalError, errorMessage & e.msg)
  return "system"
