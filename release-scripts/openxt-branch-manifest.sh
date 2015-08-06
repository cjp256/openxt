#!/bin/bash

set -e

source ./lib-maintainer-tools

if [[ $# -ne 2 || -z "${1}" || -z "${2}" ]]; then
    echo "must specify: $0 <manifest> <branch-name>"
    exit 1
fi

MANIFEST="$(readlink -f "${1}")"
BRANCH="${2}"

if [[ ! -f "${MANIFEST}" ]]; then
    echo "manifest specified does not exist!"
    exit 1
fi

checkout_and_update_manifest_repos "${MANIFEST}"

while [[ 1 ]]; do
    read -p "create branch ${BRANCH} from ${MANIFEST}? (yes/no) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

for x in $(cat ${MANIFEST}); do
    repo=$(echo ${x} | awk -F "|" '{print $1}')
    srcrev=$(echo ${x} | awk -F "|" '{print $2}')
    echo "branching ${BRANCH} for repo=${repo} with srcrev=${srcrev}"
    branch_repo "${repo}" "${BRANCH}" "${srcrev}"
done
