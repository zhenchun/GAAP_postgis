do $$
declare
        recpt text := 'gaap_sh_clean_3919';
        dest text := 'coast';
        sql text;
 begin
 drop table if exists temp_table;
 drop table if exists m_to_costal;

 sql := 'create table temp_table as
 select b.id, coalesce(st_distance(b.geom, c.geom),0) as distance
 from ' || recpt || ' as b, ' ||dest|| ' as c
 group by b.id, b.geom, c.geom';
 execute sql;

 sql :='create table m_to_costal as
 select distinct on (id) *
 from temp_table
 order by id, distance';

 execute sql;
  end;
  $$language plpgsql;





  do $$
declare
        recpt text := 'gaap_sh_clean_3919';
        dest text := 'airp_large';
        sql text;
 begin
 drop table if exists temp_table;
 drop table if exists m_to_l_airp;

 sql := 'create table temp_table as
 select b.id, coalesce(st_distance(b.geom, c.geom),0) as distance
 from ' || recpt || ' as b, ' ||dest|| ' as c
 group by b.id, b.geom, c.geom';
 execute sql;

 sql :='create table m_to_l_airp as
 select distinct on (id) *
 from temp_table
 order by id, distance';

 execute sql;
  end;
  $$language plpgsql;
