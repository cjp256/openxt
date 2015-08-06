#!/bin/bash

set -e

source ./lib-maintainer-tools

if [[ $# -ne 2 || -z "${1}" || -z "${2}" ]]; then
    echo "must specify: $0 <branch-name> <tag-name>"
    exit 1
fi

BRANCH_NAME="${1}"
TAG_NAME="${2}"

repo="$(cat repository.list | grep openxt.git)"
checkout_and_update_repo "${repo}"

tag_version=$(echo ${TAG_NAME} | awk -F v '{print $2}')
tag_major=$(echo ${tag_version} | awk -F . '{print $1}')
tag_minor=$(echo ${tag_version} | awk -F . '{print $2}')
tag_micro=$(echo ${tag_version} | awk -F . '{print $3}')
tag_nano=$(echo ${tag_version} | awk -F . '{print $4}')
tag_tuple="${tag_major}.${tag_minor}.${tag_micro}"

if [[ "v${tag_tuple}" != "${TAG_NAME}" ]]; then
    echo "invalid version tag! must be of format v#.#.# (e.g. v4.0.1)"
    exit 1
fi

while [[ 1 ]]; do
    read -p "version: set to ${TAG_NAME}? (yes/no) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

pushd clones/openxt

if ! git checkout -b "${BRANCH_NAME}" "origin/${BRANCH_NAME}" 2>/dev/null; then
    if ! git checkout "${BRANCH_NAME}"; then
        echo "unable to checkout branch, typo perhaps?"
        exit 1
    fi
fi

# verify our source ref matches expected upstream
local_srcrev="$(git rev-parse --verify HEAD)"
remote_srcrev="$(git rev-parse --verify "origin/${BRANCH_NAME}")"

if [[ "${local_srcrev}" != "${remote_srcrev}" ]]; then
    echo "invalid HEAD vs. origin/${BRANCH_NAME} -- likely unclean repo, perhaps remove ./clones ?"
    exit 1
fi

# clean out possible unintentional changes
git reset --hard

sed -i "s|^RELEASE=.*|RELEASE=\"${tag_tuple}\"|g" version
sed -i "s|^VERSION=.*|VERSION=\"${tag_tuple}\"|g" version
sed -i "s|^XC_TOOLS_MAJOR=.*|XC_TOOLS_MAJOR=\"${tag_major}\"|g" version
sed -i "s|^XC_TOOLS_MINOR=.*|XC_TOOLS_MINOR=\"${tag_minor}\"|g" version
sed -i "s|^XC_TOOLS_MICRO=.*|XC_TOOLS_MICRO=\"${tag_micro}\"|g" version

source "./version"  

if [[ "${TAG_NAME}" != "v${RELEASE}" ]]; then
    echo "openxt.git release version mismatch!"
    exit 1
fi

if [[ "${TAG_NAME}" != "v${VERSION}" ]]; then
    echo "openxt.git version version mismatch!"
    exit 1
fi

if [[ "${TAG_NAME}" != "v${XC_TOOLS_MAJOR}.${XC_TOOLS_MINOR}.${XC_TOOLS_MICRO}" ]]; then
    echo "openxt.git xctools version mismatch!"
    exit 1
fi

git diff

while [[ 1 ]]; do
    read -p "version: set to ${tag_version} - diff look ok? (yes/no) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

# all is well, commit
git commit version --signoff -m "version: set to ${tag_version}"

# push
git push origin "${BRANCH_NAME}":"${BRANCH_NAME}"

popd
