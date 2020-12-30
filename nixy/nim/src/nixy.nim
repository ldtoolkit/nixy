import nixy/cli/cmd
import nixy/cli/nixy
import nixy/cli/pkg
import nixy/cli/postgresql
import nixy/cli/python
import nixy/lib/module/pkg as pkg_lib
import nixy/lib/module/postgresql as postgresql_lib
import nixy/lib/module/python_utils as python_utils_lib
import nixy/lib/path as path_lib
import cligen


when isMainModule:
  dispatchMulti([pkg.install],
                [pkg.remove],
                [pkg.list],
                [cmd.run],
                [nixy.nixy_allow_profile],
                [nixy.nixy_disallow_profile],
                [postgresql.postgresql_init],
                [postgresql.postgresql_manage],
                [postgresql.postgresql_start],
                [postgresql.postgresql_stop],
                [python.python_venv],
                [python.python_local])
