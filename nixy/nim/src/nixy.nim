import nixy/cli/core
import nixy/cli/postgresql
import nixy/lib/core as lib
import nixy/lib/postgresql as lib_postgresql
import cligen

when isMainModule:
  dispatchMulti([core.install],
                [core.remove],
                [core.list],
                [core.run],
                [core.nixy_allow_profile],
                [core.nixy_disallow_profile],
                [postgresql.postgresql_init],
                [postgresql.postgresql_manage],
                [postgresql.postgresql_start],
                [postgresql.postgresql_stop])
