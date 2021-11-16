
do $$
declare
        recpt text := 'gaap_sh_clean_3919';
        dest text := 'points_emi_location';
        sql text;
 begin
 drop table if exists address_m_to_emi;

 sql := 'create table address_m_to_emi as
 select b.id, coalesce(st_distance(b.geom, c.geom),0) as distance, c.id as code
 from ' || recpt || ' as b, ' ||dest|| ' as c
 group by b.id, b.geom, c.geom, c.id';
 execute sql;

  end;
  $$language plpgsql;