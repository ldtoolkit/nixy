import ../errors
import python_utils

import os


proc getCommandPrefixForCurrentDirForPython*: string {.raises: [PrepareCommandError].} =
  var pythonVenv =
    try:
      getLocalVenv()
    except PythonVenvGetLocalError as e:
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
