import os


const defaultNixDir* = "~/.nix/"
const defaultNixUserChrootDir* = "~/.nix-user-chroot/"
const nixProfileSh* = "~/.nix-profile/etc/profile.d/nix.sh"
const systemLocaleArchive* = "/usr/lib/locale/locale-archive"


proc getNixUserChrootPath*(nixUserChrootDir: string): string {.raises: [].} =
  nixUserChrootDir.expandTilde / "nix-user-chroot"

proc findFileInCurrentDirOrParents*(name: string): string {.raises: [].} =
  var dir =
    try:
      getCurrentDir()
    except OSError as e:
      "/"
  result = dir / name
  var i = 0
  const maxParentCount = 128
  while dir != "/" and not result.fileExists and i < maxParentCount:
    i += 1
    dir = dir.parentDir
    result = dir / name
  if not result.fileExists:
    result = ""

proc getNixyProfileFile*: string {.raises: [].} = findFileInCurrentDirOrParents(".nixyrc")
