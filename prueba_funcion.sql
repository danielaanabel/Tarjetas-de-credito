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


create or replace function funcierre() returns void as $$
declare
i int :=0;
j int :=0;
n int :=9;
m int :=11;
fechain date :='2020-12-28';
fechac date :='2021-01-28';
fechav date :='2021-02-10';
begin
for i in i..n loop
    for j in j..m loop
        insert into cierre values(2021, j+1, i, fechain, fechac, fechav);
        if (EXTRACT(ISOYEAR FROM fechav) = 2022) then
            fechain :=fechain - cast('11 month' as interval);
            fechac :=fechac - cast('11 month' as interval);
            fechav :=fechav - cast('11 month' as interval);
        else
            fechain :=fechain + cast('1 month' as interval);
            fechac :=fechac + cast('1 month' as interval);
            fechav :=fechav + cast('1 month' as interval);
        end if;
    end loop;
end loop;
end;
$$ language plpgsql;

--select num_aleatorio(100 , 999);
select funcierre();
--select crear_cierre();

\c postgres
