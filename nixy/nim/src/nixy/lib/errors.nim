type
  NixyError* = object of CatchableError
  IncompatibleOSError* = object of NixyError
  IncompatibleOSErrorMessage* = enum
    NotGNULinux = "Operating Systems other than GNU/Linux are not supported",
    NotAmd64OrI386 = "CPUs other than amd64 and i386 are not supported",
    UnsupportedUserNamespaces = "Looks like your kernel doesn't support user namespaces for unprivileged users"
  DownloadError* = object of NixyError
  BootstrapError* = object of NixyError
  InstallError* = object of NixyError
  RemoveError* = object of NixyError
  QueryError* = object of NixyError
  RunError* = object of NixyError
  LocaleArchiveNotFoundError* = object of NixyError
