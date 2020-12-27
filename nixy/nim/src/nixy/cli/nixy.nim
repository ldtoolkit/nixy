import ../lib/nixy as lib


proc nixy_allow_profile*: int =
  lib.allowCurrentDirNixyProfile()
  return 0

proc nixy_disallow_profile*: int =
  lib.disallowCurrentDirNixyProfile()
  return 0
