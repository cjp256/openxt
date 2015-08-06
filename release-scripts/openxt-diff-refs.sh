#!/bin/bash

set -e

source ./lib-maintainer-tools

if [[ $# -ne 2 || -z "${1}" || -z "${2}" ]]; then
    echo "must specify: $0 <since-ref> <until-ref>"
    exit 1
fi

SINCE_REF="$1"
UNTIL_REF="$2"

for repo in $(cat repository.list); do
    checkout_and_update_repo "${repo}"
done

echo "***********************************"
echo "Comparing ${SINCE_REF} to ${UNTIL_REF}:"
echo "***********************************"

for repo in $(cat repository.list); do
    git_log_diff "${repo}" "${SINCE_REF}" "${UNTIL_REF}"
done
