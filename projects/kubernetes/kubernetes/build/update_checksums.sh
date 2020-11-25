#!/usr/bin/env bash
set -x
set -o errexit
set -o nounset
set -o pipefail

RELEASE_BRANCH="$1"

MAKE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "${MAKE_ROOT}/build/lib/init.sh"
if [ ! -d ${BIN_DIR}/${RELEASE_BRANCH}] ;  then
    echo "${BIN_DIR}/${RELEASE_BRANCH} not present!"
    exit 1
fi

if [ "$(go env GOROOT)" != "/usr/local/go" ]; then
    echo "GOROOT mismatch from CI environment!"
    echo "In your environment, GOROOT=$(go env GOROOT), expected \"/usr/local/go\""
    echo "This is required for reproducible builds"
fi

rm ${MAKE_ROOT}/${RELEASE_BRANCH}/checksums
# TODO: come up with a beter filter than 'kube*'
for file in $(find ${MAKE_ROOT}/_bin -name 'kube*' -type file ); do
    filepath=$(realpath --relative-base=$MAKE_ROOT $file)
    sha256sum $filepath >> ${MAKE_ROOT}/${RELEASE_BRANCH}/checksums
done
