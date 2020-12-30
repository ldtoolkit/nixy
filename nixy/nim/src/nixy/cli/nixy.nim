import ../lib/config
import ../lib/module/nixy


proc nixy_allow_profile*: int {.raises: [].} =
  try:
    nixy.allowCurrentDirNixyConfigs()
  except ConfigError as e:
    echo(e.msg)
    return 1
  return 0

proc nixy_disallow_profile*: int {.raises: [].} =
  try:
    nixy.disallowCurrentDirNixyConfigs()
  except ConfigError as e:
    echo(e.msg)
    return 1
  return 0
