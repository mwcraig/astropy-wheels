#!/bin/sh

# Usage: ./make_wheels.sh

# For this to run correctly you first need to:
# 1. Install all of the versions of python you want to use
# 2. Install virtualenvwrapper

# Change if needed to put the wheels where you want them:
WHEELHOUSE_HUB=~/wheelhouse

# These control what gets built:
pythons="python2.6 python2.7 python3.2 python3.3 python3.4"
numpys="1.5.1 1.6.2 1.7.1 1.8.1"
builds="scipy==0.14.0 astropy matplotlib==1.3.1"

# Change the default root for environments if you want:
export WORKON_HOME=~/Envs
source virtualenvwrapper.sh

# set up virtualenvs
for pyth in $pythons; do
    echo "Checking for PYTHON=$pyth"
    if [ ! -d $WORKON_HOME/$pyth ]; then
        echo "Making virtualenv for $pyth and installing wheel, cython"
        mkvirtualenv --python=/usr/bin/$pyth $pyth
        workon $pyth
        pip install wheel
        echo "Building cython..."
        pip install -q cython
    fi
done

for numpy in $numpys
do
    echo "On NUMPY=$numpy"
    WHEELHOUSE_SPOKE=$WHEELHOUSE_HUB/numpy-$numpy
    echo $WHEELHOUSE_SPOKE
    mkdir -p $WHEELHOUSE_SPOKE
    pip_wheel_cmd="pip wheel --wheel-dir=$WHEELHOUSE_SPOKE --find-links=$WHEELHOUSE_SPOKE"
    numpy_install_cmd="pip install --use-wheel --find-links=$WHEELHOUSE_SPOKE --no-index numpy==$numpy"
    for pyth in $pythons
    do
        echo "On PYTHON=$pyth"
        workon $pyth
        # remove any installed numpy so we control what version we use
        pip uninstall --yes numpy
        # try installing numpy from a wheel we've built...
        echo "Installing numpy from wheel before building wheel..."
        $numpy_install_cmd
        if [ $? -ne 0 ]; then
            echo "Building numpy=$numpy"
            $pip_wheel_cmd numpy==$numpy > numpy.$numpy.$pyth.out || continue
        fi
        echo "Installing numpy from wheel after building..."
        $numpy_install_cmd || continue
        echo "numpy installed, will proceed..."
        for build in $builds
        do
            echo "Working on build $build in $pyth with numpy=$numpy"
            # check -- do we already have this wheel??
            pip install --no-index --use-wheel --find-links=$WHEELHOUSE_SPOKE $build
            if [ $? -eq 0 ]; then
                echo "Already have wheel for $build, skipping..."
                pip uninstall --yes $build
                continue
            fi
            # ADD --no-deps below to prevent pip from grabbing a newer version of numpy than I want.
            $pip_wheel_cmd --no-deps $build > $build.$pyth.$numpy.out || echo "Failed build $build in $pyth with numpy-$numpy"
        done
    done
done
