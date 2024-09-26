#!/bin/bash
set -x
set -o pipefail

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

source $SCRIPT_DIR/testlib.bash

parseArguments "$@"
processArguments
set +e
RES=`javac -version 2>&1| tee $REPORT_FILE`
EXIT_CODE=$?

echo "Test results":
echo $RES
echo "Exit code:"
echo $EXIT_CODE


if [ $OTOOL_jresdk != "sdk" ] ; then
  echo "Expecting javac command to fail. Verifying"
  if [ $EXIT_CODE -eq 0 ]; then
    echo "This should exit as non-zero. Failing test"
    exit 1
  else
    if [[ "$RES" == *"javac: command not found"* ]] ; then
      echo "The test fails for $OTOOL_jresdk as expected, since it does not contain javac. Passing the test"
      exit 0
    else
      echo "Unexpected fail. Error message below."
      echo $RES
      exit 1
    fi
  fi
fi
