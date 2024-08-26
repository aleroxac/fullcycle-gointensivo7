ifeq ($(wildcard infra/docker/.env),)
    $(shell bash infra/docker/build-args.sh > infra/docker/.env)
endif

include infra/docker/.env
export



## ---------- IMPORTS
include infra/makefiles/utils.make
include infra/makefiles/install.make
include infra/makefiles/migrations.make
include infra/makefiles/docker.make
include infra/makefiles/compose.make
include infra/makefiles/scans.make
include infra/makefiles/main.make
