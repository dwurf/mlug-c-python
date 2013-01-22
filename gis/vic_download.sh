#!/bin/bash

sudo apt-get -y install spatialite-bin
time wget http://downloads.cloudmade.com/oceania/australia_and_new_zealand/australia/victoria/victoria.osm.bz2
time bunzip2 victoria.osm.bz2
time spatialite_osm_raw -o victoria.osm -d victoria.sqlite
