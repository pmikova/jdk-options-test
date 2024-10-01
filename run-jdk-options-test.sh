#!/bin/bash

## resolve folder of this script, following all symlinks,
## http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"
  SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$SCRIPT_DIR/$SCRIPT_SOURCE"
done
readonly SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"

set -x
set -e
set -o pipefail

if [[ -z "${WORKSPACE}" ]]; then
  WORKSPACE=~/workspace
fi

mkdir -p $WORKSPACE

pushd $WORKSPACE

if [ "x$RFaT" == "x" ]; then
  git clone https://github.com/rh-openjdk/run-folder-as-tests.git ${RFaT}
fi

bash ${WORKSPACE}/run-folder-as-tests/run-folder-as-tests.sh ${SCRIPT_DIR}/jdkOptionTests


