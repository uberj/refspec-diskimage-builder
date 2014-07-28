#!/bin/bash
# TODO. Make this script run from anywhere
if [ ! -f ./bin/functions ]; then
    echo "Couldn't find functions"
    exit 1
fi

source ./bin/functions

which disk-image-create

if [ $? -eq 1 ]; then
    die "Couldn't find disk-image-create. Activate your virtualenv?"
fi


# NOTES ON VARIABLE
# -----------------
# Only variables prefixed with DIB_ are respected by the diskimage-builder tool
# Variables prefixed with MOZ_ are to be used by this script only
# All variables should be overrideable via similarly variables found in the shell environment

MOZ_WORKING_DIR=${MOZ_WORKING_DIR:-$(pwd)}

####### DIB_ENV #######
export DIB_DATA_PATH=$MOZ_WORKING_DIR/data
export DIB_MOZ_PUPPET_REF=${DIB_MOZ_PUPPET_REF:-master}
export DIB_MOZ_PUPPET_REMOTE=${DIB_MOZ_PUPPET_REMOTE:-https://github.com/uberj/refspec-puppet.git}
export DIB_MOZ_PUPPET_REMOTE=${DIB_MOZ_PUPPET_REMOTE:-https://github.com/uberj/refspec-puppet.git}
export DIB_MOZ_BOOTSTRAP_REF=${DIB_MOZ_BOOTSTRAP_REF:-master}
export DIB_MOZ_BOOTSTRAP_REMOTE=${DIB_MOZ_BOOTSTRAP_REMOTE:-https://github.com/uberj/refspec-bootstrap.git}


MOZ_DIB_IMAGE_ARCH=${MOZ_DIB_IMAGE_ARCH:-amd64}
# NOTE: these vars can effect ./upload.sh
export MOZ_DIB_IMAGE_TYPE=${MOZ_DIB_IMAGE_TYPE:-qcow2}
export MOZ_DIB_IS_PUBLIC=${MOZ_DIB_IS_PUBLIC:-true}
export MOZ_KEYSTONE_PROFILE_PATH=${MOZ_KEYSTONE_PROFILE_PATH}
MOZ_LOCAL_ELEMENTS_PATH=${MOZ_WORKING_DIR}/elements/:${MOZ_WORKING_DIR}/heat-templates/hot/software-config/elements/:${MOZ_WORKING_DIR}/tripleo-image-elements/elements/:${MOZ_WORKING_DIR}/diskimage-builder/elements/
# TODO, all these elements might not be necessary, but including them for now because they "work"
MOZ_DIB_ELEMENTS="${MOZ_DIB_DISTRO} vm
    heat-cfntools
    heat-config-cfn-init
    heat-config
    heat-config-script
    os-collect-config
    os-refresh-config
    os-apply-config"

[ -n "$MOZ_DIB_DISTRO" ] || die "Please specifify a distro by setting MOZ_DIB_DISTRO"
[ -n "$MOZ_DIB_RELEASE" ] || die "Please specifify the $MOZ_DIB_DISTRO release by setting MOZ_DIB_RELEASE"

export DIB_RELEASE=$MOZ_DIB_RELEASE

# We need to verify a keystone profile is loaded or that MOZ_KEYSTONE_PROFILE_PATH is set.

set -x
ensure_keystone_profile
echo "Checking for glance access..."
glance image-list > /dev/null
if [ $? -ne 0 ]; then
    fail "Coulnd't access glance"
fi


#     <distro>-<distro-version>.<arch>.<mozpuppet-version>.<YYYYMMDDSS>
# Find a suitable image name that hasn't been used
BASE_IMAGE_NAME=${MOZ_DIB_DISTRO}-${MOZ_DIB_RELEASE}.${MOZ_DIB_IMAGE_ARCH}.${DIB_MOZ_PUPPET_REF}
IMAGE_PATH=${MOZ_WORKING_DIR}/mozdib/

MOZ_DIB_IMAGE_NAME=${BASE_IMAGE_NAME}.`date +%Y%m%d%S`
while true; do
    if [ -f $MOZ_DIB_IMAGE_NAME ]; then  # If it exists already, gen a new name
        MOZ_DIB_IMAGE_NAME=${IMAGE_PATH}/${BASE_IMAGE_NAME}.`date +%Y%m%d%S`
    else
        break
    fi
done
echo "Building ${IMAGE_PATH}/MOZ_DIB_IMAGE_NAME.$MOZ_DIB_IMAGE_TYPE..."

mkdir -p ${IMAGE_PATH}
errors=0
LOCK=/var/lock/.mozdib.lock
(
    # Wait for lock on $LOCK (fd 200) for 1 second
    flock -x -w 1 200 || die "Concurent builds detected. Couldn't get lock $LOCK"

    pushd $IMAGE_PATH
        # Do stuff
        ELEMENTS_PATH=$ELEMENTS_PATH:$MOZ_LOCAL_ELEMENTS_PATH disk-image-create \
            -a $MOZ_DIB_IMAGE_ARCH \
            -o $IMAGE_PATH/$MOZ_DIB_IMAGE_NAME \
            -t $MOZ_DIB_IMAGE_TYPE \
            -u \
            $MOZ_DIB_ELEMENTS

        if [ $? -ne 0 ]; then
            exit 1
        fi
    popd
    ./bin/upload.sh $MOZ_DIB_IMAGE_NAME $IMAGE_PATH/$MOZ_DIB_IMAGE_NAME.$MOZ_DIB_IMAGE_TYPE

) 200>$LOCK
