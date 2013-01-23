#!/bin/bash

osm_url=http://downloads.cloudmade.com/oceania/australia_and_new_zealand/australia/victoria/victoria.osm.bz2
osm_base=$(basename "$osm_url" .osm.bz2)

sudo apt-get -y install spatialite-bin
if [ -f $osm_base.osm -o -f ${osm_base}.osm.bz2 ]; then
    true
else
    wget "${osm_url}"
fi

if [ -f suburbs.zip -o -f ../suburbs.zip ]; then
    true
else
    wget -O suburbs.zip 'http://www.abs.gov.au/AUSSTATS/subscriber.nsf/log?openagent&2923030001ssc06aaust.zip&2923.0.30.001&Data%20Cubes&2E96C5C5F3054EDFCA25731A002140DD&0&2006&17.07.2007&Latest'
fi

if [ -f "${osm_base}".osm.bz2 -a ! -f "${osm_base}".osm ]; then
    bunzip2 "${osm_base}".osm.bz2
fi

if [ -f "${osm_base}".sqlite ]; then
    rm "${osm_base}".sqlite
fi

spatialite_osm_raw -o "${osm_base}".osm -d "${osm_base}".sqlite

spatialite "${osm_base}".sqlite << EOF
select AddGeometryColumn('osm_ways', 'Geometry', 4326, 'LINESTRING', 'XY');
select AddGeometryColumn('osm_relations', 'Geometry', 4326, 'GEOMETRYCOLLECTION', 'XY');
update osm_ways set "Geometry" = (
    select 
        LineFromText(
            replace(
                replace(
                    group_concat(st_astext(n.geometry)), 
                    '),POINT(',
                    ', '
                ),
                'POINT',
                'LINESTRING'
            ),
            4326
        )
    from 
        osm_way_refs wn,
        osm_nodes n
    where wn.node_id = n.node_id
    and wn.way_id = osm_ways.way_id
    group by wn.way_id 
)
;
-- skipping relations for now, they're a very complex type

EOF


# This method is for older ubuntus that use the old spatialite_osm_raw schema
#spatialite "${osm_base}".sqlite << EOF
#select AddGeometryColumn('osm_ways', 'Geometry', 4326, 'LINESTRING', 'XY');
#select AddGeometryColumn('osm_relations', 'Geometry', 4326, 'GEOMETRYCOLLECTION', 'XY');
#update osm_ways set "Geometry" = (
#    select 
#        LineFromText(
#            replace(
#                replace(
#                    group_concat(st_astext(n.geometry)), 
#                    '),POINT(',
#                    ', '
#                ),
#                'POINT',
#                'LINESTRING'
#            ),
#            4326
#        )
#    from 
#        osm_way_node_refs wn,
#        osm_nodes n
#    where wn.node_id = n.node_id
#    and wn.way_id = osm_ways.way_id
#    group by wn.way_id 
#)
#;
#-- skipping relations for now, they're a very complex type
#
#EOF
