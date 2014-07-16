#!/bin/bash
set -x



# TOOD, don't hardcode this
WORKING_DIR=$(pwd)

####### DIB_ENV #######
export DIB_DATA_PATH=$WORKING_DIR/data
export DIB_MOZ_PUPPET_REF=${DIB_MOZ_PUPPET_REF:-master}
export DIB_MOZ_BOOTSTRAP_REF=${DIB_MOZ_BOOTSTRAP_REF:-master}
export DIB_MOZ_BOOTSTRAP_REMOTE=${DIB_MOZ_BOOTSTRAP_REMOTE:-https://github.com/uberj/refspec-bootstrap.git}
export DIB_MOZ_PUPPET_REMOTE=${DIB_MOZ_PUPPET_REMOTE:-https://github.com/uberj/refspec-puppet.git}

MOZ_DIB_IMAGE_ARCH=${MOZ_DIB_IMAGE_ARCH:-i386}
MOZ_DIB_IMAGE_TYPE=${MOZ_DIB_IMAGE_TYPE:-qcow2}
LOCAL_ELEMENTS_PATH=$WORKING_DIR/elements/
DOCKER_ELEMENTS_PATH=/tmp/elements/
MOZ_DIB_ELEMENTS="${MOZ_DIB_DISTRO} vm mozpuppet-bootstrap"

function die {
    echo $1
    exit 1
}
[ -n "$MOZ_DIB_DISTRO" ] || die "Please specifify a distro by setting MOZ_DIB_DISTRO"
[ -n "$MOZ_DIB_RELEASE" ] || die "Please specifify the $MOZ_DIB_DISTRO release by setting MOZ_DIB_RELEASE"

export DIB_RELEASE=$MOZ_DIB_RELEASE

#     <distro>-<distro-version>.<arch>.<mozpuppet-version>
# TODO: figure out how to integrate distro version numbers
# Find a suitable image name that hasn't been used
BASE_IMAGE_NAME=${MOZ_DIB_DISTRO}-${MOZ_DIB_RELEASE}.${MOZ_DIB_IMAGE_ARCH}.${DIB_MOZ_PUPPET_REF}
IMAGE_NAME=$WORKING_DIR/mozdib/${BASE_IMAGE_NAME}.`date +%Y%m%d%S`
while true; do
    if [ -f $IMAGE_NAME ]; then  # If it exists already, gen a new name
        IMAGE_NAME=$WORKING_DIR/mozdib/${BASE_IMAGE_NAME}.`date +%Y%m%d%S`
    else
        break
    fi
done
echo "Building $IMAGE_NAME.$MOZ_DIB_IMAGE_TYPE..."

mkdir -p $WORKING_DIR/mozdib

pushd mozdib
ELEMENTS_PATH=$ELEMENTS_PATH:$LOCAL_ELEMENTS_PATH disk-image-create \
	-a $MOZ_DIB_IMAGE_ARCH \
	-o $IMAGE_NAME \
	-t $MOZ_DIB_IMAGE_TYPE \
	-p git \
    -u \
    --no-tmpfs \
	$MOZ_DIB_ELEMENTS
	# TODO: use a cache
	#--image-cache $CACHE_DIR \
popd
