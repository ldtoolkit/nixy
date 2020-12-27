# nixy
Install packages without a root using Nix

## System requirements

The only supported OS is GNU/Linux. i386/amd64 platforms are supported, but the binary is available only for amd64 (check releases). Please note, that your kernel should support user namespaces for unprivileged users. Most popular GNU/Linux distributions come with this support out of box. Please check https://github.com/nix-community/nix-user-chroot#check-if-your-kernel-supports-user-namespaces-for-unprivileged-users for more information.

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

### Python

```bash
$ nixy install python3-3.9.1
$ nixy python-venv ~/.venv
$ nixy run ~/.venv/bin/pip install ipython
$ nixy run ~/.venv/bin/ipython
$ # You can "bound" the venv to a current directory:
$ nixy python-local ~/.venv
$ # Will call ipython from ~/.venv:
$ nixy run ipython
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
