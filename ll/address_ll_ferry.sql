do $$
declare
	recpt text := 'gaap_sh_clean_3919';
	dest text := 'ferry';
	radii text[] = array['05000','03000','01500','01000','00750','00500','00400', '00300','00200', '00150', '00100', '00050'];
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
		drop table if exists address_ll_'|| dest||'_' || i || ';
		create table address_ll_'|| dest||'_' || i || ' as
		select b.id, coalesce(intsct.length, 0) as ll_'|| dest||'_s' || i || '
		from buffers as b left join
		  (select b.id, sum(st_length(st_intersection(r.geom, b.b'|| i ||'))) as length
			from '|| dest ||' as r, buffers as b
			where st_intersects(r.geom, b.b'|| i ||')
			group by b.id) as intsct
		 on b.id=intsct.id';
		execute sql;
	end loop;
end;
$$language plpgsql;
