import ../errors
import ../config
import python_utils

import os
import strutils


proc getCommandPrefixForCurrentDirForPython*: string {.raises: [PrepareCommandError].} =
  let nixyPythonVersionFile = getNixyPythonVersionFile()
  if not isEmptyOrWhitespace(nixyPythonVersionFile):
    try:
      areNixyDirConfigsAllowed(nixyPythonVersionFile)
    except ConfigReadError as e:
      raise newException(PrepareCommandError, venvActivationCommandPreparationErrorMessage & e.msg)
    var pythonVenv =
      try:
        readFile(nixyPythonVersionFile).strip.expandTilde
      except IOError as e:
        raise newException(PrepareCommandError, venvActivationCommandPreparationErrorMessage & e.msg)
    if pythonVenv != "system":
      if not pythonVenv.dirExists:
        try:
          pythonVenv = getPythonVenvDir(name = pythonVenv, create = false)
        except PythonVenvGetDirError as e:
          raise newException(PrepareCommandError,
                             venvActivationCommandPreparationErrorMessage & quoteShell(pythonVenv) & ": " & e.msg)
      try:
        getVenvActivationCommand(venvDir = pythonVenv)
      except PythonVenvError as e:
        raise newException(PrepareCommandError, e.msg)
    else:
      ""
  else:
    ""