#!/bin/bash

set -e

source ./lib-maintainer-tools

if [[ $# -ne 2 || -z "${1}" || -z "${2}" ]]; then
    echo "must specify: $0 <manifest> <tag-name>"
    exit 1
fi

MANIFEST="$(readlink -f "${1}")"
TAG_NAME="${2}"

if [[ ! -f "${MANIFEST}" ]]; then
    echo "manifest specified does not exist!"
    exit 1
fi

checkout_and_update_manifest_repos "${MANIFEST}"

echo "setting tag to ${TAG_NAME}"

while [[ 1 ]]; do
    read -p "setting tag=${TAG_NAME} using manifest=${MANIFEST}? (yes/no) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

for x in $(cat ${MANIFEST}); do
    repo=$(echo ${x} | awk -F "|" '{print $1}')
    srcrev=$(echo ${x} | awk -F "|" '{print $2}')
    echo "tagging repo=$repo with srcrev=$srcrev"
    tag_repo "${repo}" "${TAG_NAME}" "${srcrev}" "${SBIRDATE}"
done
