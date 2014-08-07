Install steps on centos6::

        yum install -y gcc python-devel python-glanceclient nc
        git clone git@github.com:uberj/refspec-diskimage-builder.git
        cd refspec-diskimage-builder/
        git submodule init
        git submodule update
        easy_install pip
        pip install virtualenvwrapper
        echo 'source virtualenvwrapper.sh' >> ~/.bashrc
        source ~/.bashrc
        mkvirtualenv dib
        pushd diskimage-builder/
        python setup.py install
        popd


The purpose of these tools is to build an image that...
* has Mozilla's puppet code primed and ready to run
* installs any base packages needed in the image

Right now only ubuntu images can be created::

  MOZ_DIB_DISTRO=ubuntu MOZ_DIB_RELEASE=trusty ./build.sh
