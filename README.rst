The purpose of these tools is to build an image that...
* has Mozilla's puppet code primed and ready to run
* installs any base packages needed in the image

Right now only ubuntu images can be created::

  MOZ_DIB_DISTRO=ubuntu MOZ_DIB_RELEASE=trusty ./build.sh
