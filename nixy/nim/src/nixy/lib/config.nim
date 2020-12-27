import os
import streams
import yaml/serialization


type
  AllowedNixyProfileDirs = seq[string]
  Config = object
    allowed_nixy_profile_dirs*: AllowedNixyProfileDirs


proc getConfigFile: string = getConfigDir() / "nixy.yaml"

proc readConfig*: Config =
  if not getConfigFile().fileExists:
    return Config()

  var s = newFileStream(getConfigFile())
  load(s, result)
  s.close()

proc writeConfig*(config: Config) =
  var s = newFileStream(getConfigFile(), fmWrite)
  dump(config, s)
  s.close()

proc isCurrentDirNixyProfileAllowed*: bool =
  let config = readConfig()
  return getCurrentDir() in config.allowedNixyProfileDirs
