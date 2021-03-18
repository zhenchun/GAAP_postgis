do $$
declare
	recpt text := 'gaap_sh_clean_3919';
	radii text[] = array['05000','03000','01500','01000','00750','00500','00400', '00300','00200', '00150', '00100', '00050'];
	i text;
        type text[] = array['cd','fd', 'fr','gd','gs','kd','qd', 'sd','xd']; --different road type
	p text;        
	sql text;
begin
	drop table if exists buffers;

	--Make buffers
	sql := 'create table buffers as	select ';
	foreach i in array radii
	loop
		sql := sql || 'st_buffer(r.geom, ' || i || ') as b' || i || ',';
	end loop;
	sql := sql || 'r.id from ' || recpt || ' as r';
	execute sql;

	--Perform intersections
	foreach i in array radii
        --outer
	loop
		raise notice '%', i;
		execute 'create index buf_indx_' || i || ' on buffers' || ' using gist (b' || i || ')';
                
                --create the output table with id as the first column
                sql := 'drop table if exists address_ll_roads_s' || i || ';
                        create table address_ll_roads_s' || i || ' as
                        select '|| recpt||'.id
                        from '|| recpt||'';
			execute sql;

                    
                     foreach p in array type
                         --inner
	                 loop
		              sql := '
		               drop table if exists '|| p ||'_' || i || ';
		               create table '|| p ||'_' || i || ' as
		               select b.id, coalesce(d.totallength, 0) as totallength
		               from buffers as b left join
		               (with intsct as (
			           select b.id, st_length(st_intersection(r.geom, b.b'|| i ||')) as length
			           from sh'||p||'_crs4499 as r, buffers as b
			           where st_intersects(r.geom, b.b'|| i ||')
		               )
		               select RLN.id, coalesce(RLN.totallength, 0) as totallength
		               from
			           (select intsct.id, sum(intsct.length) as totallength
			           from intsct
			           group by intsct.id
			           ) as RLN)
			           as d on b.id=d.id';
		               execute sql;

                           sql :=' 
                           alter table address_ll_roads_s'|| i ||' add ll_sh'|| p ||'_'|| i ||' double precision;
                           update address_ll_roads_s'|| i ||' set ll_sh'|| p ||'_'|| i ||'='|| p ||'_' || i || '.totallength from '|| p ||'_' || i || ' where address_ll_roads_s'|| i ||'.id= '|| p ||'_' || i || '.id';   
                           execute sql;
                           
                           sql :='drop table '|| p ||'_' || i || '';
                           execute sql;
                       end loop; --inner 
                 
            end loop; --outer
            end;
$$language plpgsql;