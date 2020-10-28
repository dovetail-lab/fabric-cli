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

## Configure TIBCO Flogo® Enterprise

Developers who want to edit applications using `TIBCO Flogo® Enterprise` must upload dovetail extensions as follows.

- Start TIBCO Flogo® Enterprise as described in [User's Guide](https://docs.tibco.com/pub/flogo/2.10.0/doc/pdf/TIB_flogo_2.10.0_users_guide.pdf?id=3), i.e.,

```bash
cd ${HOME}/work/dovetail-lab/flogo/2.10/bin
./start-webui.sh
```

- Open <http://localhost:8090> in Chrome web browser.
- Open [Extensions](http://localhost:8090/wistudio/extensions) link, and upload `fabricExtension.zip`, `fabclientExtension.zip`, and `functions.zip`, which are created under the dovetail-lab dev folder `${HOME}/work/dovetail-lab`.
- Create new Flogo App, and rename it as, e.g., `marble`. Select `Import App` to import a sample model, e.g., [`marble.json`](https://github.com/dovetail-lab/fabric-samples/blob/master/marble/marble.json)
- Optionally, you can then add or update the flow models of the application in the browser.
- After you are done editing, export the Flogo App, and copy the downloaded updated model file, e.g., [`marble.json`](marble.json) to the [marble](https://github.com/dovetail-lab/fabric-samples/blob/master/marble) sample folder.

If you are already a subscriber of [TIBCO Cloud Integration (TCI)](https://cloud.tibco.com/), or you plan to sign-up for a TCI trial, you can use TCI to import, edit, and then export the application models.

## Getting started

Start by looking at the [samples](https://github.com/dovetail-lab/fabric-samples), which is already downloaded under the dev folder, e.g., `${HOME}/work/dovetail-lab/fabric-samples`.

## Docker container for compile and build

In this zero-code platform, application artifacts will be edited visually in the Flogo Enterprise Console, and then built into chaincode packages or executables in a `dovetail-tools` docker container. A pre-built docker image is available in [docker hub](https://hub.docker.com/repository/docker/yxuco/dovetail-tools).

If you need to customize it, you can re-build it and publish it to docker hub using the following scripts:

```bash
make build-docker
make pub-docker
```

Note: you can edit the [Makefile](./Makefile) to specify your docker hub login `DHUB_USER`.

## Start and shutdown Hyperledger Fabric test network

You can use the Hyperledger Fabric test network to run and test application locally. The test network is already downloaded under the dev folder, e.g., `${HOME}/work/dovetail-lab/hyperledger/fabric-samples`.

Use the following scripts to start and shutdown the test network:

```bash
make start
make shutdown
```
