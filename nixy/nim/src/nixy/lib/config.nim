import errors

import os
import streams
import yaml/serialization


type
  AllowedNixyProfileDirs = seq[string]
  Config = object
    allowed_nixy_profile_dirs*: AllowedNixyProfileDirs

  ConfigError* = object of NixyError
  ConfigReadError* = object of ConfigError
  ConfigWriteError* = object of ConfigError


proc getConfigFile: string = getConfigDir() / "nixy.yaml"

proc readConfig*: Config {.raises: [ConfigReadError].} =
  try:
    if not getConfigFile().fileExists:
      return Config()

    var s = newFileStream(getConfigFile())
    defer: s.close()
    load(s, result)
  except Exception as e:
    raise newException(ConfigReadError, "Failed to read Nixy config: " & e.msg)

proc writeConfig*(config: Config) {.raises: [ConfigWriteError].} =
  try:
    var s = newFileStream(getConfigFile(), fmWrite)
    defer: s.close()
    dump(config, s)
  except Exception as e:
    raise newException(ConfigWriteError, "Failed to write Nixy config: " & e.msg)

proc isNixyProfileAllowed*(nixyProfileFile: string): bool {.raises: [ConfigReadError].} =
  let config = readConfig()
  try:
    return nixyProfileFile.parentDir in config.allowedNixyProfileDirs
  except OSError as e:
    raise newException(ConfigReadError, "Failed to get current dir: " & e.msg)
