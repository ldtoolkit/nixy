import config

import os


proc allowCurrentDirNixyProfile* =
  var config = readConfig()
  if not isCurrentDirNixyProfileAllowed():
    config.allowedNixyProfileDirs.add(getCurrentDir())
  writeConfig(config)

proc disallowCurrentDirNixyProfile* =
  var config = readConfig()
  if isCurrentDirNixyProfileAllowed():
    config.allowedNixyProfileDirs.delete(config.allowedNixyProfileDirs.find(getCurrentDir()))
  writeConfig(config)
