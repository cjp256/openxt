#!/bin/bash

set -e

source ./lib-maintainer-tools

if [[ $# -ne 2 || -z "${1}" || -z "${2}" ]]; then
    echo "must specify: $0 <branch-name> <manifest-out>"
    exit 1
fi

MANIFEST="$(readlink -f "${2}")"
BRANCH="${1}"

if [[ -f "${MANIFEST}" ]]; then
    echo "manifest specified already exists!"
    exit 1
fi

touch "${MANIFEST}"

if [[ $? -ne 0 ]]; then
    echo "unable to create manifest @ ${MANIFEST}"
    exit 1
fi

for repo in $(cat repository.list); do
    checkout_and_update_repo "${repo}"
done

for repo in $(cat repository.list); do
    echo "adding ${repo} to manifest..."
    manifest "${repo}" "${BRANCH}" ${MANIFEST}
done
