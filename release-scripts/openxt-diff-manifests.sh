#!/bin/bash

set -e

source ./lib-maintainer-tools

if [[ $# -ne 2 || -z "${1}" || -z "${2}" ]]; then
    echo "must specify: $0 <since-manifest> <until-manifest>"
    exit 1
fi

SINCE_MANIFEST="$(readlink -f "${1}")"
UNTIL_MANIFEST="$(readlink -f "${2}")"

if [[ ! -f "${SINCE_MANIFEST}" ]]; then
    echo "manifest=${SINCE_MANIFEST} specified does not exist!"
    exit 1
fi

if [[ ! -f "${UNTIL_MANIFEST}" ]]; then
    echo "manifest=${UNTIL_MANIFEST} specified does not exist!"
    exit 1
fi

checkout_and_update_manifest_repos "${UNTIL_MANIFEST}"

echo "***********************************"
echo "Comparing ${SINCE_MANIFEST} to ${UNTIL_MANIFEST}:"
echo "***********************************"

for x in $(cat ${SINCE_MANIFEST}); do
    repo=$(echo ${x} | awk -F "|" '{print $1}')
    since_srcrev=$(echo ${x} | awk -F "|" '{print $2}')
    until_srcrev=$(cat ${UNTIL_MANIFEST} | grep "${repo}" | awk -F "|" '{print $2}')
    git_log_diff "${repo}" "${since_srcrev}" "${until_srcrev}"
done
