import errors

import os
import strutils


type
  StoreDirError* = object of NixyError


proc getStoreDir*(name: string = ""): string {.raises: [StoreDirError].} =
  try:
    result = getHomeDir() / ".nixy"
    if not isEmptyOrWhitespace(name):
      result = result / name
    result.createDir
  except OSError, IOError:
    raise newException(StoreDirError, "Failed to get store dir " & quoteShell(result) & ": " & getCurrentExceptionMsg())
