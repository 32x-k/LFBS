#!/usr/bin/env bash
set -e

if [[ $UID != 0 ]]; then
    echo "You have to run this as root." 1>&2
    exit 1
fi

if ! type docker >/dev/null 2>&1; then
    echo "You have to install docker." 1>&2
    exit 1
fi

_usage () {
    echo "usage ${0} [options]"
    echo
    echo " General options:"
    echo "    -o | --build-opiton \"[options]\"     send the build option to ./lfbs"
    echo "    -c | --clean                          Enable --no-cache option when build docker image"
    echo "    -h | --help                           This help message and exit"
    echo
}

# Start parse options
ARGUMENT="${@}"
while (( $# > 0 )); do
    case ${1} in
        -o | --build-opiton)
            BUILD_OPT="${2}"
            shift 2
            ;;
        -c | --clean)
            NO_CACHE="--no-cache" # Enable --no-cache option
            shift 1
            ;;
        -h | --help)
            _usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            msg_error "Invalid argument '${1}'"
            _usage 1
            ;;
    esac
done


# End parse options

SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd ${SCRIPT_DIR}
docker build ${NO_CACHE} -t lfbs-build:latest .
docker run -t -i --privileged -v ${SCRIPT_DIR}/out:/lfbs/out -v /usr/lib/modules:/usr/lib/modules:ro -v ${SCRIPT_DIR}/cache:/lfbs/cache lfbs-build "${BUILD_OPT}"
