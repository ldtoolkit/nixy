import ../lib/config
import ../lib/module/python
import ../lib/module/python_utils
import ../lib/path


proc python_venv*(name: seq[string],
                  venv_dir: string = "",
                  python_executable: string = defaultPythonExecutable,
                  nix_user_chroot_dir: string = defaultNixUserChrootDir,
                  nix_dir = defaultNixDir,
                  use_system_locale_archive: bool = false): int
                 {.raises: [].} =
  try:
    python.venv(name = name[0],
                venvDir = venvDir,
                pythonExecutable = pythonExecutable,
                nixUserChrootDir = nixUserChrootDir,
                nixDir = nixDir,
                useSystemLocaleArchive = useSystemLocaleArchive)
  except PythonVenvCreationError as e:
    echo(e.msg)
    return 1
  return 0

proc python_local*(name: seq[string], venv_dir: string = ""): int {.raises: [].} =
  try:
    python.local(name = name[0], venvDir = venv_dir)
  except ConfigError, PythonVenvLocalError:
    echo(getCurrentExceptionMsg())
    return 1
  return 0
