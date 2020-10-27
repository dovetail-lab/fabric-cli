#!/bin/bash
# Copyright © 2018. TIBCO Software Inc.
#
# This file is subject to the license terms contained
# in the license file that is distributed with this file.

# initialize development environment
# - check golang environment
# - check Flogo environment
# - download dovetail-lab projects
# - download Hyperledger Fabric samples

# Usage:
# ./init.sh [ FE_HOME ]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; echo "$(pwd)")"
LAB_PATH=${SCRIPT_DIR}/../..
FE_ROOT=${1:-${FE_HOME}}

function checkGo {
  local v=$(go version | awk '{print $3}')
  if [ -z "$v"]; then
    echo "Golang is not installed.  Please install Go 1.14 or later."
  elif [ "$v" < "go1.14" ]; then
    echo "Go version $v.  We recommand go1.14.4 or later."
  else
    echo "Go version $v"
  fi
}

function checkFlogo {
  local v=$(flogo -v | awk '{print $4}')
  if [ -z "$v"]; then
    echo "Flogo cli not found.  install the latest version..."
    go get -u github.com/project-flogo/cli/...
  else
    echo "Flogo cli version $v.  We recommand version 0.10.0 or later."
  fi
}

function checkFlogoEnterprise {
  if [ -z "${FE_ROOT}" ]; then
    # set standard FE_HOME
    FE_ROOT=${LAB_PATH}/flogo
  fi
  local s=$(find ${FE_ROOT} -name start-webui.sh)
  if [ "${s##*/}" == "start-webui.sh" ]; then
    local d=$(dirname ${s%/*})
    echo "Found Flogo Enterprise version ${d##*/} under ${FE_ROOT}"
  else
    echo "We recommend installing Flogo Enterprise 2.10 or later under ${LAB_PATH}/flogo"
  fi
}

function checkDovetailLabProjects {
  cd ${LAB_PATH}
  if [ ! -d "${LAB_PATH}/fabric-chaincode" ]; then
    echo "clone github.com/dovetail-lab/fabric-chaincode"
    git clone https://github.com/dovetail-lab/fabric-chaincode.git
  fi
  if [ ! -d "${LAB_PATH}/fabric-client" ]; then
    echo "clone github.com/dovetail-lab/fabric-clent"
    git clone https://github.com/dovetail-lab/fabric-client.git
  fi
  if [ ! -d "${LAB_PATH}/fabric-samples" ]; then
    echo "clone github.com/dovetail-lab/fabric-samples"
    git clone https://github.com/dovetail-lab/fabric-samples.git
  fi
  if [ ! -d "${LAB_PATH}/fabric-operation" ]; then
    echo "clone github.com/dovetail-lab/fabric-operation"
    git clone https://github.com/dovetail-lab/fabric-operation.git
  fi
  echo "Downloaded all dovetail-lab projects under ${LAB_PATH}"
}

function checkHyperledgerFabric {
  if [ ! -d "${LAB_PATH}/hyperledger/fabric-samples" ]; then
    echo "download Hyperledger Fabric samples to ${LAB_PATH}/hyperledger..."
    mkdir -p ${LAB_PATH}/hyperledger
    cd ${LAB_PATH}/hyperledger
    curl -sSL http://bit.ly/2ysbOFE | bash -s -- 1.4.9 1.4.9
    cd fabric-samples
    git checkout tags/v1.4.8
  fi
}

checkGo
checkFlogo
checkFlogoEnterprise
checkDovetailLabProjects
checkHyperledgerFabric
