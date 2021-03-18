do $$
declare
	recpt text := 'gaap_sh_clean_3919';
	river text := 'huangpu_river';
	radii text[] = array['5000','3000','1500','1000','750','500','400', '300','200', '150', '100', '50'];
	i text;
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
	loop
		raise notice '%', i;
		execute 'create index buf_indx_' || i || ' on buffers' || ' using gist (b' || i || ')';

		sql := '
		drop table if exists ll_huangpu_' || i || ';
		create table ll_huangpu_' || i || ' as
		select b.id, coalesce(intsct.length, 0) as riverlength
		from buffers as b left join
		  (select b.id, sum(st_length(st_intersection(r.geom, b.b'|| i ||'))) as length
			from '|| river ||' as r, buffers as b
			where st_intersects(r.geom, b.b'|| i ||')
			group by b.id) as intsct
		 on b.id=intsct.id';
		execute sql;
	end loop;
end;
$$language plpgsql;
