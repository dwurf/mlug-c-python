#!/bin/sh

echo Not sure if this is still necessary
echo \#sudo apt-get -y install libgdal-dev
virtualenv --no-site-packages .
. bin/activate
pip install gdal
sed -i 's/#include "gdal/#include "gdal\/gdal/' build/gdal/extensions/gdal_wrap.cpp
sed -i 's/#include "cpl/#include "gdal\/cpl/' build/gdal/extensions/gdal_wrap.cpp
sed -i 's/#include "cpl/#include "gdal\/cpl/' build/gdal/extensions/ogr.cpp
