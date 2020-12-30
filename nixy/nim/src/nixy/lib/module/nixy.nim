import ../config

import os


proc allowCurrentDirNixyConfigs* {.raises: [ConfigReadError, ConfigWriteError].} =
  var config = readConfig()
  let currentDir =
    try:
      getCurrentDir()
    except OSError as e:
      raise newException(ConfigWriteError, "Failed to get current dir: " & e.msg)
  try:
    if not areNixyDirConfigsAllowed(currentDir):
      config.allowedNixyDirConfigsDirs.add(currentDir)
    writeConfig(config)
  except OSError as e:
    raise newException(ConfigWriteError, "Failed to write Nixy config: " & e.msg)

proc disallowCurrentDirNixyConfigs* {.raises: [ConfigReadError, ConfigWriteError].}=
  var config = readConfig()
  let currentDir =
    try:
      getCurrentDir()
    except OSError as e:
      raise newException(ConfigWriteError, "Failed to get current dir: " & e.msg)
  try:
    if areNixyDirConfigsAllowed(currentDir):
      config.allowedNixyDirConfigsDirs.delete(config.allowedNixyDirConfigsDirs.find(currentDir))
    writeConfig(config)
  except OSError as e:
    raise newException(ConfigWriteError, "Failed to write Nixy config: " & e.msg)
