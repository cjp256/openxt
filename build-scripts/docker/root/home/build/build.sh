#!/bin/bash -x

set -e

if [[ -z "${BRANCH}" ]]; then
    BRANCH="master"
fi

if [[ -z "${BUILD_NAME}" ]]; then
    BUILD_NAME="${BRANCH}"
fi

SOURCES_DIR="/work/sources/${BUILD_NAME}"
BUILD_DIR="/work/builds/${BUILD_NAME}"
CERTS_DIR="/work/certs"

if [[ ! -f /work/certs/prod-cakey.pem ]]; then
    mkdir -p /work/certs
    openssl genrsa -out /work/certs/prod-cakey.pem 2048
fi

if [[ ! -f /work/certs/dev-cakey.pem ]]; then
    openssl genrsa -out /work/certs/dev-cakey.pem 2048
fi

if [[ ! -f /work/certs/prod-cacert.pem ]]; then
    openssl req -new -x509 -key /work/certs/prod-cakey.pem -out /work/certs/prod-cacert.pem -days 1095 -batch
fi

if [[ ! -f /work/certs/dev-cacert.pem ]]; then
    openssl req -new -x509 -key /work/certs/dev-cakey.pem -out /work/certs/dev-cacert.pem -days 1095 -batch
fi

if [[ ! -d "${SOURCES_DIR}" ]]; then
    mkdir -p "${SOURCES_DIR}"
    for repo in $(curl -s "https://api.github.com/users/openxt/repos?per_page=100" | jq '.[].name' | cut -d '"' -f 2); do
        git clone --mirror "git://github.com/openxt/${repo}.git" "${SOURCES_DIR}/${repo}.git"
        git clone "${SOURCES_DIR}/${repo}.git" -b "${BRANCH}" "${SOURCES_DIR}/${repo}"
        pushd "${SOURCES_DIR}/${repo}"
        git remote add openxt git://github.com/openxt/${repo}.git
        popd
    done
fi

if [[ ! -d "${BUILD_DIR}" ]]; then
    mkdir -p /work/builds
    git clone ${SOURCES_DIR}/openxt.git -b "${BRANCH}" "${BUILD_DIR}"

    pushd "${BUILD_DIR}"

    cp example-config .config
    cat <<EOF >>.config
REPO_PROD_CACERT="${CERTS_DIR}/prod-cacert.pem"
REPO_DEV_CACERT="${CERTS_DIR}/dev-cacert.pem"
REPO_DEV_SIGNING_CERT="${CERTS_DIR}/dev-cacert.pem"
REPO_DEV_SIGNING_KEY="${CERTS_DIR}/dev-cakey.pem"
OPENXT_GIT_MIRROR="${SOURCES_DIR}"
OPENXT_GIT_PROTOCOL="file"
EOF

    cat .config
    ./do_build.sh -s setupoe

    echo 'DL_DIR="/work/oe-downloads"' >> build/conf/local.conf

    popd
fi

pushd "${BUILD_DIR}"
./do_build.sh -s initramfs,stubinitramfs,dom0,uivm,ndvm,syncvm,installer,installer2,ship
popd
