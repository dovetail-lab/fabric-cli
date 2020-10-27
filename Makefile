MAKEFILE_THIS := $(lastword $(MAKEFILE_LIST))
SRC_PATH      := $(patsubst %/,%,$(dir $(abspath $(MAKEFILE_THIS))))
LAB_PATH      ?= $(SRC_PATH)/..
FAB_PATH      ?= $(LAB_PATH)/hyperledger/fabric-samples
FE_HOME       ?= $(LAB_PATH)/flogo/2.10

.PHONY: all
all: build deploy

.PHONY: clean
clean:
	rm -Rf $(TOOL_PATH)/work/$(APP_NAME)

.PHONY: build
build: $(APP_FILE) clean
	$(TOOL_PATH)/build.sh cds -f $(APP_FILE) -n $(APP_NAME)

.PHONY: flogo.zip
flogo.zip: $(FE_HOME)
	$(SRC_PATH)/fe-config/fe-pack.sh $(FE_HOME)

.PHONY: cli-init
cli-init:
	docker exec cli bash -c 'cd scripts; ./fn-init-marble.sh'

.PHONY: cli-test
cli-test:
	docker exec cli bash -c 'cd scripts; ./fn-test-marble.sh'

.PHONY: metadata
metadata:
	fabric-tools metadata -f $(APP_FILE) -m $(SRC_PATH)/contract-metadata/metadata.json -g $(SRC_PATH)/contract-metadata/metadata.gql -o $(SRC_PATH)/contract-metadata/override.json

.PHONY: clean-client
clean-client:
	rm -Rf $(TOOL_PATH)/work/$(CLIENT_NAME)

.PHONY: build-client
build-client: $(CLIENT_FILE) clean-client
	$(TOOL_PATH)/build.sh client -f $(CLIENT_FILE) -n $(CLIENT_NAME) -s $(CLIENT_OS)

.PHONY: run
run:
	FLOGO_APP_PROP_RESOLVERS=env FLOGO_APP_PROPS_ENV=auto PORT=8989 FLOGO_LOG_LEVEL=DEBUG FLOGO_SCHEMA_SUPPORT=true FLOGO_SCHEMA_VALIDATION=false CRYPTO_PATH=$(FAB_PATH)/first-network/crypto-config $(TOOL_PATH)/work/$(CLIENT_NAME)/$(CLIENT_NAME)_$(CLIENT_OS)_amd64

.PHONY: build-fe-client
build-fe-client: $(FE_CLIENT_FILE) clean-client
	$(TOOL_PATH)/build.sh client -f $(FE_CLIENT_FILE) -n $(CLIENT_NAME) -s $(CLIENT_OS)

.PHONY: start
start:
	cd $(FAB_PATH)/first-network && ./byfn.sh up -a -n -s couchdb -i 1.4.9

.PHONY: shutdown
shutdown:
	cd $(FAB_PATH)/first-network && ./byfn.sh down
	-docker rm $(docker ps -a | grep dev-peer | awk '{print $1}')
	-docker rmi $(docker images | grep dev-peer | awk '{print $3}')
