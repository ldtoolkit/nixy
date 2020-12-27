import nixy/cli/core
import nixy/cli/nixy
import nixy/cli/postgresql
import nixy/cli/python
import nixy/lib/core as lib
import nixy/lib/postgresql as lib_postgresql
import nixy/lib/python as lib_python
import cligen

when isMainModule:
  dispatchMulti([core.install],
                [core.remove],
                [core.list],
                [core.run],
                [nixy.nixy_allow_profile],
                [nixy.nixy_disallow_profile],
                [postgresql.postgresql_init],
                [postgresql.postgresql_manage],
                [postgresql.postgresql_start],
                [postgresql.postgresql_stop],
                [python.python_venv],
                [python.python_local])
