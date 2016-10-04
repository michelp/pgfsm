EXTENSION = sqlfsm
DATA = sqlfsm--0.0.1.sql

# postgres build stuff
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
