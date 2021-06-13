drop database if exists probfun;
create database probfun;

\c probfun

create table cierre(
    año int,
    mes int,
    terminacion int,
    fechainicio date,
    fechacierre date,
    fechavto    date
);
alter table cierre   add constraint cierre_pk   primary key (año, mes, terminacion);

create or replace function num_aleatorio(a int, b int) returns int as $$
declare
c int;
begin
c := trunc(random()* (b-a)+a);
return c;
end;
$$ language plpgsql;


--funcion para hacer los insert en la tabla cierre
create or replace function funcierre() returns void as $$
declare
	i int :=0;
	j int :=0;
	n int :=9;
	m int :=11;
	fecha_inicio date :='2020-12-28';
	fecha_cierre date :='2021-01-27';
	fecha_vencimiento date :='2021-02-10';
begin
for i in i..n loop
    for j in j..m loop
        insert into cierre values(2021, j+1, i, fecha_inicio, fecha_cierre, fecha_vencimiento);
        if (EXTRACT(ISOYEAR FROM fecha_vencimiento) = 2022) then
            fecha_inicio := fecha_inicio - cast('11 month' as interval);
            fecha_cierre := fecha_cierre - cast('11 month' as interval);
            fecha_vencimiento := fecha_vencimiento - cast('11 month' as interval);
        else
            fecha_inicio := fecha_inicio + cast('1 month' as interval);
            fecha_cierre := fecha_cierre+ cast('1 month' as interval);
            fecha_vencimiento := fecha_vencimiento + cast('1 month' as interval);
        end if;
    end loop;
end loop;
end;
$$ language plpgsql;

--select num_aleatorio(100 , 999);
select funcierre();
--select crear_cierre();
select * from cierre;

\c postgres
