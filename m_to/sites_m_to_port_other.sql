


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
        recpt text := 'gaap_sites_55';
        dest text := 'port_other';
        sql text;
begin

              sql :=' drop table if exists sites_m_to_'|| dest ||';        
              create table sites_m_to_'|| dest ||' as 
              with nn as (
	          select distinct r.id, r.geom, 
	          nnid(r.geom, 1000, 2, 100, '''|| dest ||''', ''gid'', ''geom'') as nn_all
	          from '|| recpt ||' as r
	          )
	          select DMR.id, DMR.m_to_'|| dest ||'
	          from
                  (select nn.id, st_distance(nn.geom, t.geom) as m_to_'|| dest ||'
	          from nn left join '|| dest ||' as t 
	          on nn.nn_all = t.gid
	          ) as DMR';
               

 execute sql;
  end;
  $$language plpgsql;
