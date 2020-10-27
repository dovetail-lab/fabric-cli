# fabric-cli

This package provides scripts to get started on zero-code development of Hyperledger Fabric applications.

## Setup development environment

First, create a folder for `dovetail-lab` projects and install TIBCO Flogo Enterprise 2.10, which requires license and can be downloaded from [here](https://edelivery.tibco.com/storefront/eval/tibco-flogo-enterprise/prod11810.html).

```bash
# 0. assume that you already downloaded and installed Go from https://golang.org/doc/install

# 1. create dovetail-lab dev folder, e.g.
mkdir -p ${HOME}/work/dovetail-lab
cd ${HOME}/work/dovetail-lab

# 2. install Flogo Enterprise package downloaded from TIBCO
unzip TIB_flogo_2.10.0_macosx_x86_64.zip

# 3. download fabric-cli project from github
git clone https://github.com/dovetail-lab/fabric-cli.git

# 4. download and configure open-source artifacts
cd fabric-cli
make
```

## Getting started

Start by looking at the [samples](https://github.com/dovetail-lab/fabric-samples), which is already downloaded under the dev folder, e.g., `${HOME}/work/dovetail-lab/fabric-samples`.

## Docker container for compile and build

In this zero-code platform, application artifacts will be edited visually in the Flogo Enterprise Console, and then built into chaincode packages or executables in a `dovetail-tools` docker container. A pre-built docker image is available in [docker hub](https://hub.docker.com/repository/docker/yxuco/dovetail-tools).

If you need to customize it, you can re-build it and publish it to docker hub using the following scripts:

```bash
make build-docker
make pub-docker
```

Note: you can edit the [Makefile](.Makefile) to specify your docker hub login `DHUB_USER`.

## Start and shutdown Hyperledger Fabric test network

You can use the Hyperledger Fabric test network to run and test application locally. The test network is already downloaded under the dev folder, e.g., `${HOME}/work/dovetail-lab/hyperledger/fabric-samples`.

Use the following scripts to start and shutdown the test network:

```bash
make start
make shutdown
```
