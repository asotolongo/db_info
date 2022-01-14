EXTENSION = db_info
DATA = db_info--0.1.0.sql db_info--0.1.0--0.2.0.sql
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

