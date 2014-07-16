#!/bin/bash
set -x



IMAGE_ARCH=i386
ELEMENTS="ubuntu vm mozpuppet-bootstrap"
# TOOD, don't hardcode this
WORKING_DIR=$(pwd)
DOCKER_TAG=mozdib
IMAGE_NAME='image'
IMAGE_TYPE='qcow2'
#QEMU_OPTIONS='compat=0.10'

LOCAL_ELEMENTS_PATH=$WORKING_DIR/elements/
DOCKER_ELEMENTS_PATH=/tmp/elements/

####### DIB_ENV #######
export DIB_DATA_PATH=$WORKING_DIR/data
DIB_MOZ_PUPPET_REF=${DIB_MOZ_PUPPET_REF:-master}
DIB_MOZ_BOOTSTRAP_REF=${DIB_MOZ_BOOTSTRAP_REF:-master}
DIB_MOZ_BOOTSTRAP_REMOTE=${DIB_MOZ_BOOTSTRAP_REMOTE:-https://github.com/uberj/refspec-bootstrap.git}
DIB_MOZ_PUPPET_REMOTE=${DIB_MOZ_PUPPET_REMOTE:-https://github.com/uberj/refspec-puppet.git}

#docker images | grep -q $DOCKER_TAG
#if [ $? -ne 0 ]; then
#    docker build --tag=$DOCKER_TAG .
#fi

mkdir -p $WORKING_DIR/mozdib

# Until we are installing services, we don't need this
#docker run \
#	--privileged=true  \
#	-v /root/mozdib/mozdib:$WORKING_DIR \
#	-v $LOCAL_ELEMENTS_PATH:$DOCKER_ELEMENTS_PATH \
#	-w $WORKING_DIR \
#	-e ELEMENTS_PATH=/tmp/elements \
#	$DOCKER_TAG \
#	disk-image-create \
#		-a $IMAGE_ARCH \
#		-o $IMAGE_NAME \
#		-t $IMAGE_TYPE \
#		--qemu-img-options $QEMU_OPTIONS \
#		$ELEMENTS
pushd mozdib
ELEMENTS_PATH=$ELEMENTS_PATH:$LOCAL_ELEMENTS_PATH disk-image-create \
	-a $IMAGE_ARCH \
	-o $IMAGE_NAME \
	-t $IMAGE_TYPE \
	-p git \
	$ELEMENTS
	# TODO: use a cache
	#--image-cache $CACHE_DIR \
popd
