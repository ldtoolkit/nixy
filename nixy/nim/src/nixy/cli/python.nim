import ../lib/config
import ../lib/core
import ../lib/errors
import ../lib/python


proc python_venv*(venv_dir: seq[string],
                  python_executable: string = defaultPythonExecutable,
                  nix_user_chroot_dir: string = defaultNixUserChrootDir,
                  nix_dir = defaultNixDir,
                  use_system_locale_archive: bool = false): int
                 {.raises: [].} =
  try:
    python.venv(venvDir = venvDir[0],
                pythonExecutable = pythonExecutable,
                nixUserChrootDir = nixUserChrootDir,
                nixDir = nixDir,
                useSystemLocaleArchive = useSystemLocaleArchive)
  except RunError as e:
    echo(e.msg)
    return 1
  return 0

proc python_local*(venv_dir: seq[string]): int {.raises: [].} =
  try:
    python.local(venvDir[0])
  except ConfigError, PythonVenvLocal:
    echo(getCurrentExceptionMsg())
    return 1
  return 0
