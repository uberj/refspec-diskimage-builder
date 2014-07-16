#!/bin/bash
set -x

# TODO. Make this script run from anywhere
if [ ! -f ./bin/functions ]; then
    echo "Couldn't find functions"
    exit 1
fi

source ./bin/functions

[ -n "$1" ] || die "Expected image name as first argument"
[ -n "$2" ] || die "Expected image path as second argument"

MOZ_DIB_IMAGE_TYPE=${MOZ_DIB_IMAGE_TYPE:-qcow2}
MOZ_DIB_IS_PUBLIC=${MOZ_DIB_IS_PUBLIC:-true}

ensure_keystone_profile

echo "Uploading image as tenant $OS_TENANT_NAME..."
glance image-create --name $1 --disk-format $MOZ_DIB_IMAGE_TYPE --container-format bare --is-public $MOZ_DIB_IS_PUBLIC --file $2
