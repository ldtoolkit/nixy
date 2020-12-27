import ../lib/config
import ../lib/nixy as lib


proc nixy_allow_profile*: int {.raises: [].} =
  try:
    lib.allowCurrentDirNixyProfile()
  except ConfigError as e:
    echo(e.msg)
    return 1
  return 0

proc nixy_disallow_profile*: int {.raises: [].} =
  try:
    lib.disallowCurrentDirNixyProfile()
  except ConfigError as e:
    echo(e.msg)
    return 1
  return 0
