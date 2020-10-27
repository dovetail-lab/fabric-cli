MAKEFILE_THIS := $(lastword $(MAKEFILE_LIST))
SRC_PATH      := $(patsubst %/,%,$(dir $(abspath $(MAKEFILE_THIS))))
LAB_PATH      ?= $(SRC_PATH)/..
FAB_PATH      ?= $(LAB_PATH)/hyperledger/fabric-samples
FE_HOME       ?= $(LAB_PATH)/flogo/2.10
DHUB_USER     ?= changeme

.PHONY: all
all: init flogo.zip

.PHONY: clean
clean:
	rm -Rf $(SRC_PATH)scripts/work/*

.PHONY: init
init:
	$(SRC_PATH)/scripts/init.sh ${FE_HOME}

.PHONY: flogo.zip
flogo.zip: $(FE_HOME)/bin/start-webui.sh
	$(SRC_PATH)/fe-config/fe-pack.sh $(FE_HOME)

.PHONY: build-docker
build-docker:
	cd $(SRC_PATH)/scripts && ./docker-image.sh build

.PHONY: pub-docker
pub-docker:
	docker login -u $(DHUB_USER)
	cd $(SRC_PATH)/scripts && ./docker-image.sh upload -u $(DHUB_USER) -d
	
.PHONY: start
start: $(FAB_PATH)/first-network
	cd $(FAB_PATH)/first-network && ./byfn.sh up -a -n -s couchdb -i 1.4.9

.PHONY: shutdown
shutdown: $(FAB_PATH)/first-network
	cd $(FAB_PATH)/first-network && ./byfn.sh down
	-docker rm $(docker ps -a | grep dev-peer | awk '{print $1}')
	-docker rmi $(docker images | grep dev-peer | awk '{print $3}')
