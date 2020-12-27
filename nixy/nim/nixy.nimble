# Package

version       = "0.1.1"
author        = "Roman Inflianskas"
description   = "Install packages without a root using Nix"
license       = "Apache-2.0"
srcDir        = "src"
binDir        = "bin"
bin           = @["nixy"]


# Dependencies

requires "nim >= 1.4.2", "cligen >= 1.3.2", "https://github.com/flyx/NimYAML.git#head"
