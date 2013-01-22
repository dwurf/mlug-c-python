#!/bin/bash

sudo apt-get -y install spatialite-bin
wget http://downloads.cloudmade.com/oceania/australia_and_new_zealand/australia/australian_capital_territory/australian_capital_territory.osm.bz2
wget http://downloads.cloudmade.com/oceania/australia_and_new_zealand/australia/australian_capital_territory/australian_capital_territory.administrative.osm.bz2

time bunzip2 australian_capital_territory.osm.bz2
time bunzip2 australian_capital_territory.administrative.osm.bz2

time spatialite_osm_raw -o australian_capital_territory.osm -d australian_capital_territory.sqlite
time spatialite_osm_raw -o australian_capital_territory.administrative.osm -d australian_capital_territory.administrative.sqlite


time spatialite australian_capital_territory.sqlite << EOF
attach 'australian_capital_territory.administrative.sqlite' as admin;

begin;
insert or replace into osm_nodes select * from admin.osm_nodes;
insert or replace into osm_ways select * from admin.osm_ways;
insert or replace into osm_relations select * from admin.osm_relations;
insert or replace into osm_node_tags select * from admin.osm_node_tags;
insert or replace into osm_way_tags select * from admin.osm_way_tags;
insert or replace into osm_relation_tags select * from admin.osm_relation_tags;
insert or replace into osm_way_node_refs select * from admin.osm_way_node_refs;
insert or replace into osm_relation_node_refs select * from admin.osm_relation_node_refs;
insert or replace into osm_relation_relation_refs select * from admin.osm_relation_relation_refs;
insert or replace into osm_relation_way_refs select * from admin.osm_relation_way_refs;
commit;
detach database admin;
.quit

EOF


time spatialite australian_capital_territory.sqlite << EOF
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

