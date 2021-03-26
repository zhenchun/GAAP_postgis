do $$
declare
	recpt text := 'gaap_sh_clean_3919';
	landuse text := 'sh_lu_thu_2015_4499_fixed';
	radii text[] = array['03000','01500','01000', '00750','00500','00400','00300','00150', '00100', '00050'];
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
		drop table if exists address_lu_' || i || ';
		create table address_lu_' || i || ' as
		with intsct as (
			select b.id, c.dn, sum(st_area(st_intersection(c.geom, b.b'|| i ||'))) as area
			from '|| landuse ||' as c, buffers as b
			where st_intersects(c.geom, b.b'|| i ||')
      group by b.id, c.dn

		)
    select SFS.id, coalesce(SFS.Surface, 0) as lu_surface_s' || i || ',
		coalesce(CRP.Cropland, 0) as lu_cropland_s' || i || ',
    coalesce(FRT.Forest, 0) as lu_forest_s' || i || ',
    coalesce(GRD.Grassland, 0) as lu_grassland_s' || i || ',
    coalesce(SRD.Shrubland, 0) as lu_shrubland_s' || i || ',
    coalesce(WET.Wetland, 0) as lu_wetland_s' || i || ',
    coalesce(WAT.Water, 0) as lu_water_s' || i || ',
    coalesce(IPV.Impersfc, 0) as lu_impersfc_s' || i || ',
    coalesce(BAR.Bareland, 0) as lu_bareland_s' || i || '
    from

          (select b.id, sum(intsct.area) as Surface
          from buffers as b left join intsct
          on b.id = intsct.id
          group by b.id
          ) as SFS
    left join
        (select b.id, sum(intsct.area) as Cropland
        from buffers as b left join intsct
        on b.id = intsct.id
	where intsct.dn = ''11''
	or intsct.dn = ''12''
        or intsct.dn = ''13''
        or intsct.dn = ''14''
        or intsct.dn = ''15''
        group by b.id
	) as CRP
    on SFS.id = CRP.id
    left join
          (select b.id, sum(intsct.area) as Forest
          from buffers as b left join intsct
          on b.id = intsct.id
          where intsct.dn = ''21''
          or intsct.dn = ''22''
          or intsct.dn = ''23''
          or intsct.dn = ''25''
          group by b.id
          ) as FRT
    on SFS.id = FRT.id
    left join
         (select b.id, sum(intsct.area) as Grassland
         from buffers as b left join intsct
         on b.id = intsct.id
         where intsct.dn = ''32''
         or intsct.dn = ''33''
         group by b.id
			 ) as GRD
    on SFS.id = GRD.id
    left join
        (select b.id, sum(intsct.area) as Shrubland
        from buffers as b left join intsct
        on b.id = intsct.id
        where intsct.dn = ''41''
        or intsct.dn = ''42''
        group by b.id
			) as SRD
    on SFS.id = SRD.id
    left join
       (select b.id, sum(intsct.area) as Wetland
       from buffers as b left join intsct
       on b.id = intsct.id
       where intsct.dn = ''51''
       or intsct.dn = ''52''
       or intsct.dn = ''53''
       group by b.id
       ) as WET
    on SFS.id = WET.id
    left join
      (select b.id, coalesce(intsct.area, 0) as Water
      from buffers as b left join intsct
      on b.id = intsct.id
      where intsct.dn = ''60''
      group by b.id
		  ) as WAT
    on SFS.id = WAT.id
    left join
      (select b.id, coalesce(intsct.area, 0) as Impersfc
      from buffers as b left join intsct
      on b.id = intsct.id
      where intsct.dn = ''80''
      group by b.id
      ) as IPV
    on SFS.id = IPV.id
    left join
      (select b.id, coalesce(intsct.area, 0) as Bareland
      from buffers as b left join intsct
      on b.id = intsct.id
      where intsct.dn = ''90''
      group by b.id
		) as BAR
    on SFS.id = BAR.id';
    execute sql;
    end loop;
end;

$$language plpgsql;
