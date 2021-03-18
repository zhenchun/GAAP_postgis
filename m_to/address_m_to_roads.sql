
--data was provided by Yihui
--shgs (shanghai highway)  shgd (national roads) shkd (express roads) shsd (provincial roads) shxd (county roads) shcd (village roads)  shqd (other roads)



create or replace function  nnid(nearto geometry, initialdistance real, distancemultiplier real, 
maxpower integer, nearthings text, nearthingsidfield text, nearthingsgeometryfield  text)
returns integer as $$
declare 
  sql text;
  result integer;
begin
  sql := ' select ' || quote_ident(nearthingsidfield) 
      || ' from '   || quote_ident(nearthings)
      || ' where st_dwithin($1, ' 
      ||   quote_ident(nearthingsgeometryfield) || ', $2 * ($3 ^ $4))'
      || ' order by st_distance($1, ' || quote_ident(nearthingsgeometryfield) || ')'
      || ' limit 1';
  for i in 0..maxpower loop
     execute sql into result using nearto             -- $1
                                , initialdistance     -- $2
                                , distancemultiplier  -- $3
                                , i;                  -- $4
     if result is not null then return result; end if;
  end loop;
  return null;
end
$$ language 'plpgsql' stable;


do $$
declare 
	recpt text := 'gaap_sh_clean_3919';
	type text[] = array['cd','fd', 'fr','gd','gs','kd','qd', 'sd','xd'];
	p text;
        sql text;
begin
	--find nearest neighbours
        foreach p in array type	
        loop
               
              sql :=' drop table if exists '|| p ||';        
              create table '|| p ||' as 
              with nn as (
		select distinct r.id, r.geom, 
		nnid(r.geom, 1000, 2, 100, ''sh'|| p ||'_crs4499'', ''gid'', ''geom'') as nn_all
		from '|| recpt ||' as r
	        )
	        select DMR.id, DMR.distance
	        from
		     (select nn.id, st_distance(nn.geom, t.geom) as distance
		     from nn left join sh'|| p ||'_crs4499 as t 
		     on nn.nn_all = t.gid
		     ) as DMR'; 
                execute sql;
                end loop;
    
                sql := 'drop table if exists address_m_to_roads;
                        create table address_m_to_roads as
                        select '|| recpt||'.id
                        from '|| recpt||'';
			execute sql;
           foreach p in array type	
           loop
               
                     sql :=' alter table address_m_to_roads add m_to_'|| p ||' double precision;
                     update address_m_to_roads set m_to_'|| p ||'='|| p ||'.distance from '|| p ||' where address_m_to_roads.id= '|| p ||'.id';   
                execute sql;
                end loop;
          

            foreach p in array type	
            loop
                    sql :='drop table '||p||'';
                    execute sql;
                    end loop;
                    end;
$$language plpgsql;


