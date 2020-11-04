#!/bin/bash
# Copyright © 2018. TIBCO Software Inc.
#
# This file is subject to the license terms contained
# in the license file that is distributed with this file.

# run this script in dovetail-tools docker container to build chaincode cds package
# usage;
#   build-cds.sh <model> <cc-name> <cc-version> <package>

MODEL=${1}
NAME=${2}
VERSION=${3}
PACKAGE=${4:-"tar"}
echo "build-cds.sh ${MODEL} ${NAME} ${VERSION} ${PACKAGE}"
MODEL_DIR=${WORK}/${NAME}
FLOGO=${GOPATH}/bin/flogo
env

function create {
  if [ -d "/tmp/${NAME}" ]; then
    echo "cleanup old workspace /tmp/${NAME}"
    rm -rf /tmp/${NAME}
  fi
  mkdir /tmp/${NAME}
  cp ${MODEL_DIR}/${MODEL} /tmp/${NAME}
  cd /tmp/${NAME}
  ${FLOGO} create --cv ${FLOGO_VER} --verbose -f ${MODEL} ${NAME}
  rm ${NAME}/src/main.go
  cp ${HOME}/fabric-cli/shim/main.go ${NAME}/src

  if [ -d "${MODEL_DIR}/META-INF" ]; then
    cp -rf ${MODEL_DIR}/META-INF /tmp/${NAME}/${NAME}/src
  fi

  cp ${HOME}/fabric-cli/scripts/codegen.sh /tmp/${NAME}/${NAME}
  cd /tmp/${NAME}/${NAME}
  ./codegen.sh
  cd src
  chmod +x gomodedit.sh
  ./gomodedit.sh
}

function build {
  cd /tmp/${NAME}/${NAME}/src
  go mod edit -module "github.com/dovetail-lab/fabric-chaincode/${NAME}"
  go mod edit -replace=github.com/project-flogo/core=${FLOGO_REPO}/core@${FLOGO_REPO_VER}
  go mod edit -replace=github.com/project-flogo/flow=${FLOGO_REPO}/flow@${FLOGO_REPO_VER}

  cd ..
  ${FLOGO} build -e --verbose
  cd src
  go mod vendor
  go build -mod vendor -o ${MODEL_DIR}/${NAME}_linux_amd64
}

# build cds package for Fabric v1.4
function packageV1 {
  echo "build chaincode cds package ..."
  if [ -d "/opt/gopath/src/github.com/chaincode/${NAME}" ]; then
    echo "cleanup old chaincode ${NAME}"
    rm -rf /opt/gopath/src/github.com/chaincode/${NAME}
  fi

  # Note: must run the following steps outside of the src folder
  cd ${HOME}
  mkdir -p /opt/gopath/src/github.com/chaincode
  cp -Rf /tmp/${NAME}/${NAME}/src /opt/gopath/src/github.com/chaincode/${NAME}
  fabric-tools package -n ${NAME} -v ${VERSION} -p /opt/gopath/src/github.com/chaincode/${NAME} -o ${MODEL_DIR}/${NAME}_${VERSION}.cds
  chmod +r ${MODEL_DIR}/${NAME}_${VERSION}.cds
  echo "chaincode cds package: ${MODEL_DIR}/${NAME}_${VERSION}.cds"

  if [ -d "${MODEL_DIR}/${NAME}" ]; then
    echo "cleanup old chaincode source ${MODEL_DIR}/${NAME}"
    rm -rf ${MODEL_DIR}/${NAME}
  fi
  cp -Rf /tmp/${NAME}/${NAME}/src ${MODEL_DIR}/${NAME}
}

# build tar.gz for Fabric v2.2
function package {
  echo "build chaincode package tar.gz ..."
  cd /tmp/${NAME}/${NAME}/src
  local importPath=$(go list -f {{.ImportPath}})
  cd ..
  echo '{"path":"'${importPath}'","type":"golang","label":"'${NAME}_${VERSION}'"}' > metadata.json
  tar cfz code.tar.gz src
  tar cfz ${MODEL_DIR}/${NAME}_${VERSION}.tar.gz metadata.json code.tar.gz
  chmod +r ${MODEL_DIR}/${NAME}_${VERSION}.tar.gz
  echo "chaincode package: ${MODEL_DIR}/${NAME}_${VERSION}.tar.gz"

  if [ -d "${MODEL_DIR}/${NAME}" ]; then
    echo "cleanup old chaincode source ${MODEL_DIR}/${NAME}"
    rm -rf ${MODEL_DIR}/${NAME}
  fi
  echo "copy source files to ${MODEL_DIR}/${NAME} ..."
  cp -Rf /tmp/${NAME}/${NAME}/src ${MODEL_DIR}/${NAME}
}

create
build

if [ ! -f "${MODEL_DIR}/${NAME}_linux_amd64" ]; then
  echo "failed to build chaincode"
  exit 1
fi

if [ "${PACKAGE}" == "tar" ]; then
  package
else
  packageV1
fi