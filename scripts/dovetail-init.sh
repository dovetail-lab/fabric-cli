#!/bin/bash
# Copyright © 2018. TIBCO Software Inc.
#
# This file is subject to the license terms contained
# in the license file that is distributed with this file.

# run this script in docker container to setup for dovetail
# assume $WORK is mounted and contain Flogo Enterprise lib named flogo.zip

if [ -f "${WORK}/flogo.zip" ]; then
  unzip ${WORK}/flogo.zip
  rm ${WORK}/flogo.zip
fi

git clone https://${DOVETAIL_REPO}/fabric-cli.git
git clone https://${DOVETAIL_REPO}/fabric-chaincode.git
git clone https://${DOVETAIL_REPO}/fabric-client.git

go get -u github.com/project-flogo/cli/...

cd fabric-cli/fabric-tools
go install
