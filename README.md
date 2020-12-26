# nixy
Install packages without a root using Nix

## Usage

### Basics

```bash
$ nixy install lsd
$ nixy run lsd
$ nixy list
$ nixy remove lsd
$ nixy list --available | grep lsd
```

### PostgreSQL

```bash
$ nixy install --unstable postgresql-13.1
$ nixy postgresql-init
$ nixy postgresql-start
$ nixy postgresql-stop
$ nixy postgresql-manage -- createdb $USER -h ~/.postgresql/
$ nixy run -- psql -h ~/.postgresql/
```

## Building the static binary

```bash
$ # Install musl
$ cd nixy/nim/
$ # (this will download LibreSSL and compile it for you!)
$ nim musl -d:libressl src/nixy.nim
$ # Observe the binary in bin/
```

Read more here: https://scripter.co/nim-deploying-static-binaries/
