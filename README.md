astropy-wheels
==============

Made an Ubuntu 12.04.4 LTS VM for building the wheels.

Needed to install several things before running ``make_wheels.sh``:

+ Used ``wget`` to get pip:
    + ``wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py``
    + ``python get-pip.py``
+ Use ``pip`` to get virtual environments working: ``pip install virtualenvwrapper``
+ In that environment, install wheel: ``pip install wheel``
+ ``apt-get install``
    + for building any python stuff: ``python-dev``
    + for ``scipy``: ``libblas-dev liblapack-dev gfortran``

+ to make different virtualenvs for different versions of python you need to
actually install those versions with ``apt-get`` first (e.g ``apt-get install
python3.2``). This is different than ``conda``. **AND** you better get the dev
parts too: ``apt-get install python3.2-dev``...otherwise you can't actually
build against them.

To actually make the wheels: ``./make_wheels.sh``

**Note on getting older/newer pythons:** Turns out 2.6 and 3.3 are not "standard" packages on ubuntu 12.04. To get them, do:

```bash
sudo apt-get install python-software-properties  # this gets you add-apt-repository
sudo add-apt-repository ppa:fkrull/deadsnakes
sudo apt-get update
sudo apt-get install python2.6 python2.6-dev python3.3 python3.3-dev
```

See this [SO article](http://askubuntu.com/questions/125342/how-can-i-install-python-2-6-on-12-04) for details.
