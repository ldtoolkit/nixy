import errors

import os
import streams
import yaml/serialization


type
  AllowedNixyDirConfigsDirs = seq[string]
  Config = object
    allowed_nixy_dir_configs_dirs*: AllowedNixyDirConfigsDirs

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

proc areNixyDirConfigsAllowed*(nixyDirConfigDir: string): bool {.raises: [ConfigReadError].} =
  let config = readConfig()
  try:
    nixyDirConfigDir in config.allowedNixyDirConfigsDirs
  except OSError as e:
    raise newException(ConfigReadError, "Failed to get current dir: " & e.msg)
