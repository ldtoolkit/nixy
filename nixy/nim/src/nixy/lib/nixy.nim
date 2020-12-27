import config

import os


proc allowCurrentDirNixyProfile* {.raises: [ConfigReadError, ConfigWriteError].} =
  var config = readConfig()
  try:
    if not isCurrentDirNixyProfileAllowed():
      config.allowedNixyProfileDirs.add(getCurrentDir())
    writeConfig(config)
  except OSError as e:
    raise newException(ConfigWriteError, "Failed to write Nixy config: " & e.msg)

proc disallowCurrentDirNixyProfile* {.raises: [ConfigReadError, ConfigWriteError].}=
  var config = readConfig()
  try:
    if isCurrentDirNixyProfileAllowed():
      config.allowedNixyProfileDirs.delete(config.allowedNixyProfileDirs.find(getCurrentDir()))
    writeConfig(config)
  except OSError as e:
    raise newException(ConfigWriteError, "Failed to write Nixy config: " & e.msg)
