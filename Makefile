EXTENSION = pgfsm
DATA = pgfsm--0.0.1.sql

OUTS := $(wildcard expected/*.out)
MDS := $(patsubst expected/%.out,docs/%.md,$(OUTS))

.PHONY: doctest

doctest: $(MDS)

docs:
	mkdir -p docs

docs/%.md: expected/%.out | docs
	python3 doctestify.py $< $@

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
REGRESS := $(patsubst sql/%.sql,%,$(wildcard sql/*.sql))
TESTS := $(REGRESS)
include $(PGXS)
