#!/bin/bash
set -x
set -o pipefail

## resolve folder of this script, following all symlinks,
## http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
SCRIPT_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SCRIPT_SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  LIBCQA_SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"
  SCRIPT_SOURCE="$(readlink "$SCRIPT_SOURCE")"
  # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  [[ $SCRIPT_SOURCE != /* ]] && SCRIPT_SOURCE="$LIBCQA_SCRIPT_DIR/$SCRIPT_SOURCE"
done
readonly LIBCQA_SCRIPT_DIR="$( cd -P "$( dirname "$SCRIPT_SOURCE" )" && pwd )"

parseArguments() {
  for a in "$@"
  do
    case $a in
      --jdk=*)
        ARG_JDK="${a#*=}"
      ;;
      --report-dir=*)
        ARG_REPORT_DIR="${a#*=}"
      ;;
      *)
        echo "Unrecognized argument: '$a'" >&2
        exit 1
      ;;
    esac
  done
}


processArguments() {
  if [[ -z $ARG_JDK ]] ; then
    echo "JDK image was not specified" >&2
    exit 1
  elif ! readlink -e "$ARG_JDK" >/dev/null
  then
    echo "JDK image was not found" >&2
    exit 1
  else
    readonly JAVA_DIR="$( readlink -e "$ARG_JDK" )"
  fi

  if [[ -z $ARG_REPORT_DIR ]] ; then
    echo "Report dir was not specified" >&2
    exit 1
  else
    readonly REPORT_DIR="$( readlink -m "$ARG_REPORT_DIR" )"
    mkdir -p "$REPORT_DIR"
  fi

  readonly REPORT_FILE="$REPORT_DIR/report.txt"
  readonly CONTAINERQA_PROPERTIES="$REPORT_DIR/../containerQa.properties"
}

