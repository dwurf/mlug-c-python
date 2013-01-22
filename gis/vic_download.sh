#!/bin/bash

sudo apt-get -y install spatialite-bin
wget http://downloads.cloudmade.com/oceania/australia_and_new_zealand/australia/victoria/victoria.osm.bz2

time bunzip2 victoria.osm.bz2

time spatialite_osm_raw -o victoria.osm -d victoria.sqlite

time spatialite victoria.sqlite << EOF
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
        osm_way_node_refs wn,
        osm_nodes n
    where wn.node_id = n.node_id
    and wn.way_id = osm_ways.way_id
    group by wn.way_id 
)
;
-- skipping relations for now, they're a very complex type

EOF

