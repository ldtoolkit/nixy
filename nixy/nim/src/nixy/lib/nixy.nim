import config
import core

import os


proc allowCurrentDirNixyProfile* {.raises: [ConfigReadError, ConfigWriteError].} =
  var config = readConfig()
  try:
    let nixyProfileFile = getNixyProfileFile()
    if not isNixyProfileAllowed(nixyProfileFile):
      config.allowedNixyProfileDirs.add(nixyProfileFile.parentDir)
    writeConfig(config)
  except OSError as e:
    raise newException(ConfigWriteError, "Failed to write Nixy config: " & e.msg)

proc disallowCurrentDirNixyProfile* {.raises: [ConfigReadError, ConfigWriteError].}=
  var config = readConfig()
  try:
    let nixyProfileFile = getNixyProfileFile()
    if isNixyProfileAllowed(nixyProfileFile):
      config.allowedNixyProfileDirs.delete(config.allowedNixyProfileDirs.find(nixyProfileFile.parentDir))
    writeConfig(config)
  except OSError as e:
    raise newException(ConfigWriteError, "Failed to write Nixy config: " & e.msg)
