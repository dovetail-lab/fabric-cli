#!/bin/bash
# This script packs Flogo Enterprise components enabled for Go modules into flogo.zip
#
# caller should pass Flogo Enterprise home folder name, e.g.,
# ./fe-pack.sh "/usr/local/tibco/flogo/2.10"
#
# if no arg is specified, it uses the value of env ${FE_HOME} as the FE home folder.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"; echo "$(pwd)")"
feroot=${1:-"${FE_HOME}"}
fedir=$(dirname "${feroot}")
feversion=${feroot##*/}

if [ ! -d "${fedir}/data/localstack/wicontributions/Tibco/General" ]; then
  echo "${feroot} is not a valid FE home directory"
  exit 1
fi

cd ${SCRIPT_DIR}
if [ -f "flogo.zip" ]; then
  echo "${SCRIPT_DIR}/flogo.zip already exists, skip fe-pack.sh"
  exit 0
fi

if [ ! -f "${feroot}/lib/core/src/git.tibco.com/git/product/ipaas/wi-contrib.git/engine/go.mod" ]; then
  echo "initialize FE components to support Go module"
  ./fe-init ${feroot}
fi

if [ -d "${SCRIPT_DIR}/flogo" ]; then
  echo "clean up old flogo folder ${SCRIPT_DIR}/flogo"
  rm -Rf ${SCRIPT_DIR}/flogo
fi

echo "copy FE lib files to ${SCRIPT_DIR}/flogo"
mkdir -p ${SCRIPT_DIR}/flogo/${feversion}/lib/core
cp -Rf ${feroot}/lib/core/src ${SCRIPT_DIR}/flogo/${feversion}/lib/core

mkdir -p ${SCRIPT_DIR}/flogo/data/localstack/wicontributions/Tibco
cp -Rf ${fedir}/data/localstack/wicontributions/Tibco/General ${SCRIPT_DIR}/flogo/data/localstack/wicontributions/Tibco

echo "update go mod files"
localfedir=$(echo $fedir | sed 's/\//\\\//g')
modfiles=$(find ${SCRIPT_DIR}/flogo/data/localstack/wicontributions/Tibco/General -name go.mod)
for f in ${modfiles}; do
  sed -i -e 's/'${localfedir}'/\/root\/flogo/g' $f
  rm ${f}-e
done

enginemod=${SCRIPT_DIR}/flogo/${feversion}/lib/core/src/git.tibco.com/git/product/ipaas/wi-contrib.git/engine/go.mod
sed -i -e 's/'${localfedir}'/\/root\/flogo/g' ${enginemod}
rm ${enginemod}-e

echo "create ${SCRIPT_DIR}/flogo.zip"
zip -r flogo.zip flogo
