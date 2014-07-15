#!/bin/bash
set -x

IMAGE_ARCH=i386
ELEMENTS="ubuntu vm mozpuppet-config mozpuppet-bootstrap"
# TOOD, don't hardcode this
WORKING_DIR=/root/mozdib
DOCKER_TAG=mozdib
IMAGE_NAME='image'
IMAGE_TYPE='qcow2'
#QEMU_OPTIONS='compat=0.10'

LOCAL_ELEMENTS_PATH=/root/mozdib/elements/
DOCKER_ELEMENTS_PATH=/tmp/elements/

docker images | grep -q $DOCKER_TAG
if [ $? -ne 0 ]; then
    docker build --tag=$DOCKER_TAG .
fi

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
