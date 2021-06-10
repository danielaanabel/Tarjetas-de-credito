drop database if exists basedatos;
create database basedatos;

\c basedatos

create table cliente(
    nrocliente  int,
    nombre      text,
    apellido    text,
    domicilio   text,
    telefono    char(12)
);

create table tarjeta(
    nrotarjeta  char(16),
    nrocliente  int,
    validadesde char(6),
    validahasta char(6),
    codseguridad char(4),
    limitecompra decimal(8,2),
    estado  char(10)
);

create table comercio(
    nrocomercio int,
    nombre      text,
    domicilio   text,
    codigopostal char(8),
    telefono    char(12)
);

create table compra(
    nrooperacion int,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(7,2),
    pagado  boolean
);

create table rechazo(
    nrorechazo  serial,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(7,2),
    motivo  text
);

create table cierre(
    año int,
    mes int,
    terminacion int,
    fechainicio date,
    fechacierre date,
    fechavto    date
);

create table cabecera(
    nroresumen  int,
    nombre      text,
    apellido    text,
    domicilio   text,
    nrotarjeta  char(16),
    desde   date,
    hasta   date,
    vence   date,
    total   decimal(8,2)
);

create table detalle(
    nroresumen  int,
    nrolinea    int,
    fecha   date,
    nombrecomercio text,
    monto   decimal(7,2)
);

create table alerta(
    nroalerta   int,
    nrotarjeta  char(16),
    fecha   timestamp,
    nrorechazo  int,
    codalerta   int,
    descripcion text
);

create table consumo(
    nrotarjeta  char(16),
    codseguridad char(4),
    nrocomercio int,
    monto   decimal(7,2)
);

alter table cliente  add constraint cliente_pk  primary key (nrocliente);
alter table tarjeta  add constraint tarjeta_pk  primary key (nrotarjeta);
alter table comercio add constraint comercio_pk primary key (nrocomercio);
alter table compra   add constraint compra_pk   primary key (nrooperacion);
alter table rechazo  add constraint rechazo_pk  primary key (nrorechazo);
alter table cierre   add constraint cierre_pk   primary key (año, mes, terminacion);
alter table cabecera add constraint cabecera_pk primary key (nroresumen);
alter table detalle  add constraint detalle_pk  primary key (nroresumen, nrolinea);
alter table alerta   add constraint alerta_pk   primary key (nroalerta);

alter table compra   add constraint compra_nrotarjeta_fk   foreign key (nrotarjeta)  references tarjeta(nrotarjeta);
alter table compra   add constraint compra_nrocomercio_fk  foreign key (nrocomercio) references comercio(nrocomercio);

alter table rechazo  add constraint rechazo_nrotarjeta_fk  foreign key (nrotarjeta)  references tarjeta(nrotarjeta);
alter table rechazo  add constraint rechazo_nrocomercio_fk foreign key (nrocomercio) references comercio(nrocomercio);

alter table cabecera add constraint cabecera_nrotarjeta_fk foreign key (nrotarjeta)  references tarjeta(nrotarjeta);

alter table detalle  add constraint detalle_nroresumen_fk  foreign key (nroresumen)  references cabecera(nroresumen);

alter table alerta   add constraint alerta_nrotarjeta_fk   foreign key (nrotarjeta)  references tarjeta(nrotarjeta);
alter table alerta   add constraint alerta_nrorechazo_fk   foreign key (nrorechazo)  references rechazo(nrorechazo);

alter table consumo  add constraint consumo_nrotarjeta_fk  foreign key (nrotarjeta)  references tarjeta(nrotarjeta);
alter table consumo  add constraint consumo_nrocomercio_fk foreign key (nrocomercio) references comercio(nrocomercio);

--tarjetas
insert into tarjeta values('4286283215095190', 1, '201709', '202208', '114', 45000.00, 'vigente');
insert into tarjeta values('4532449515464319', 2, '202001', '202412', '881', 30000.00, 'vigente');
insert into tarjeta values('4716905901199213', 3, '202108', '202607', '311', 150000.00, 'vigente');
insert into tarjeta values('4539760286740064', 4, '202204', '202703', '553', 35000.00, 'vigente');
insert into tarjeta values('4916197097056062', 5, '202010', '202509', '103', 45000.00, 'anulada');
insert into tarjeta values('4532157860627139', 6, '202004', '202503', '802', 42000.00, 'anulada');
insert into tarjeta values('4449942525596585', 7, '202010', '202509', '552', 120000.00, 'vigente');
insert into tarjeta values('4929028998516745', 8, '201610', '202109', '412', 110000.00, 'suspendida');
insert into tarjeta values('4916558526474988', 9, '201604', '202103', '633', 65000.00, 'anulada');--vencida
insert into tarjeta values('4456844734152285', 10, '201707', '202206', '853', 35000.00, 'anulada');
insert into tarjeta values('5305073210930499', 11, '201707', '202206', '271', 140000.00, 'vigente');
insert into tarjeta values('5115874922952014', 12, '202008', '202507', '647', 70000.00, 'suspendida');
insert into tarjeta values('5433516727758253', 13, '201802', '202301', '345', 150000.00, 'vigente');
insert into tarjeta values('5200557813577356', 14, '201707', '202206', '112', 120000.00, 'anulada');
insert into tarjeta values('5425807573408337', 15, '201712', '202211', '879', 43000.00, 'vigente');
insert into tarjeta values('5255982663365344', 16, '201906', '202405', '768', 120000.00, 'suspendida');
insert into tarjeta values('5535292533476491', 17, '201805', '202304', '876', 170000.00, 'vigente');
insert into tarjeta values('5425758312840399', 18, '202005', '202504', '881', 80000.00, 'vigente');
insert into tarjeta values('340869936801114', 17, '201907', '202406', '675', 90000.00, 'vigente'); 
insert into tarjeta values('342888106007110', 18, '202103', '202602', '127', 120000.00, 'vigente');
insert into tarjeta values('343263611209214', 19, '201909', '202408', '901', 200000.00, 'anulada');
insert into tarjeta values('377829618815820', 20, '201804', '202303', '320', 90000.00, 'suspendida');


--comercios
insert into comercio values(1, 'Coto', 'Belgrano 960', 'B1619JHU','034844458867');
insert into comercio values(2, 'Sodimac','Constituyentes 1370','B1619HUU','112658423658');
insert into comercio values(3, 'Buen Gusto', 'Av. Libertador 3072', 'C1245YTD','541126598965');
insert into comercio values(4, 'Cafeteria Victor', 'Juan Gutierrez 1150', 'B1613GAE', '541178451245');
insert into comercio values(5, 'Libreria Alondra', 'Mateo Churich 130', 'B1619JGB', '541125584518');
insert into comercio values(6, 'Carrefour', 'Los Andes 458', 'B1608OKL', '541126154879');
insert into comercio values(7, 'El Boulevard', 'General Peron 377', 'B1610HGU', '541128964712');
insert into comercio values(8, 'Rapanui', 'Juan Domingo Peron 1974', 'C1456NSM', '541126597841');
insert into comercio values(9, 'Ñoquis Artesanales', 'Balcarce 50', 'C1064KCF', '541143443600');
insert into comercio values(10, 'McDonalds', 'Hipolito Yrigoyen 267', 'B1610LPN','541126455468');
insert into comercio values(11, 'Starbucks', '25 de Mayo 2254', 'B1609KGJ','541148897234');
insert into comercio values(12, 'Parrilla El Chorizon', 'Blandengues 483', 'B1611HGE', '541136223879');
insert into comercio values(13, 'Optica Casimiro', 'Juan B Justo 2020', 'C1032BND', '541121145469');
insert into comercio values(14, 'Ferreteria El Cosito', 'Peru 1654', 'B1663ERF', '541136458159');
insert into comercio values(15, 'Farmacia Favaloro', 'Remedios de Escalada 392', 'B1619HJU', '541125698741');
insert into comercio values(16, 'Servicio Tecnico LG', 'Marie Curie 506', 'B1600KIB', '541125896734');
insert into comercio values(17, 'Loteria de la provincia', 'Cayetano Bourdet 2390', 'B1619PER', '541123698564');
insert into comercio values(18, 'Supermercado Puma', 'Cordoba 212', 'B1610GBF', '541128955864');
insert into comercio values(19, 'Aberturas Pepe', '9 de Julio 3004', 'C1040JUG', '541126897468');
insert into comercio values(20, 'Cinemark', 'Constituyentes 2078', 'B1620MVU', '541128969864');


--clientes 
insert into cliente values(1,'Daniela Anabel','Oviedo','San Martin 3814','541130569988');
insert into cliente values(2,'Fernando','Ferreyra','Benito Lynch 2206','541156441305');
insert into cliente values(3, 'Elias','Goñez', 'Valparaiso 2050','541128898392');
insert into cliente values(4,'Romina','Segretin','Uruguay 790','541154085062');
insert into cliente values(5,'Fabian','García Gómez','Av. Alem 368','541140495127');
insert into cliente values(6,'Matheo Samuel','García','Av. Callao 1311','541146155914');
insert into cliente values(7,'Sabrina Rosalia','Ramirez','Av. Sáenz 945','541130360237');
insert into cliente values(8,'Sara Valeria','Hernández','Av. Cabildo 2523','541128447247');
insert into cliente values(9,'Alicia Grisel','Gómez','Cura Brochero 1053','541161206314');
insert into cliente values(10,'Joana Elizabeth','Villarreal','Palpa 1020','541164294818');
insert into cliente values(11,'Ignacio Ariel','Perez','Paso de los patos 2508','541189768847');
insert into cliente values(12,'Lucia Daniela','Benitez','Av. Rivadavia 2199','541124361554');
insert into cliente values(13,'Maximiliano Ezequiel','Fernandez','Obrien 2460','541167353600');
insert into cliente values(14,'Cristian Elias','Oviedo','Yatasto 1749','541126858087');
insert into cliente values(15,'Carolina Noelia','Diaz','Falucho 853','541151955038');
insert into cliente values(16,'Agustina','Lopez','Ricardo Rojas 1183','541141612153');
insert into cliente values(17,'Luciano Damian','Mansilla','Av. Eva Duarte de Perón 904','541136471202');
insert into cliente values(18,'Hernan Daniel','Rondelli','Nazca 1065','541127146757');
insert into cliente values(19,'Leandro David','Gimenez','Juan Maria Gutiérrez 1150','541125405212');
insert into cliente values(20,'Rodrigo Ezquiel','Palacios','Pablo Areguati 299','541124511771');

--consumos
insert into consumo values('4716905901199213', '311', 10, 750.00);
insert into consumo values('5305073210930499', '271', 6, 1500.00);
insert into consumo values('5535292533476491', '876', 1, 3000.00);
insert into consumo values('4916197097056062', '103', 11, 500.00);
insert into consumo values('5425758312840399', '881', 15, 1000.00);
insert into consumo values('4449942525596585', '552', 12, 2000.00);
insert into consumo values('4286283215095190', '114', 14, 550.00);


 

create or replace function funcierre() returns void as $$
declare
	i int := 0;
	j int := 0;
	n int := 9;
	m int := 11;
	fecha_inicio date := '2020-12-28';
	fecha_cierre date := '2021-01-28';
	fecha_vencimiento date := '2021-02-10';
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


create function autorizar_compra(nro_tarjeta char(16), cod_seguridad char(4), nro_comercio int, p_monto decimal(7,2)) returns boolean as $$
declare
    fecha_actual timestamp := current_date; --fecha actual sin la hora
begin
    if not exists(select * from tarjeta where nrotarjeta = nro_tajeta or verificar_vigencia(select validahasta from tarjeta where nrotarjeta = nro_tajeta)) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tajeta, nro_comercio, fecha_actual, p_monto, 'tarjeta no valida o no vigente');
        return false;
    end if;
    if cod_seguridad != (select codseguridad from tarjeta where nrotarjeta = nro_tajeta) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tajeta, nro_comercio, fecha_actual, p_monto, 'codigo de seguridad invalido');
        return false;
    end if;
    if ((select sum(monto) from compra where nrotarjeta = nro_tarjeta) + p_monto) > (select limitecompra from tarjeta where nrotarjeta = nro_tarjeta) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tajeta, nro_comercio, fecha_actual, p_monto, 'supera limite de tareta');
        return false;
    end if;
    if (verificar_vigencia(select validahasta from tarjeta where nrotarjeta = nro_tajeta)) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tajeta, nro_comercio, fecha_actual, p_monto, 'plazo de vigencia expirado');
        return false;
    end if;
    if 'suspendida' == (select estado from tarjeta where nrotarjeta = nro_tajeta) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tajeta, nro_comercio, fecha_actual, p_monto, 'la tarjeta se encuentra suspendida');
        return false;
    else
        --se autoriza la compra
        insert into compra (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tarjeta, nro_comercio, fecha_actual, p_monto, true);
        return true;
    end if;
end;
$$ language plpgsql;


create function func_alerta_rechazo() returns trigger as $$
declare
    nro_alerta int;
    undia timestamp := '2021-01-28'-'2021-01-27';
begin
    nro_alerta = (select count(*) from alerta) + 1;
    insert into alerta values(nro_alerta, new.nrotarjeta, new.tiempo, new.nrorechazo, 0, 'se produjo un rechazo');

    if (select count(*) from rechazo where nrotarjeta = new.nrotarjeta and motivo = 'supera limite de tareta') > 1 then 
        --if (fecha-new.fecha < 1 dia)
        update tarjeta set estado = 'suspendida' where nrotarjeta = new.nrotarjeta;
        nro_alerta = (select count(*) from alerta) + 1;
        insert into alerta values(nro_alerta, new.nrotarjeta, new.tiempo, new.nrorechazo, 32, 'supero el limite de compra mas una vez');
    end if;    
    return new;
end;
$$ language plpgsql;

create trigger rechazo_trg
after insert on rechazo
for each row
execute procedure func_alerta_rechazo();

--create function func_alerta_rechazo() returns trigger as $$

--end;
--$$ language plpgsql;

--create trigger compra_trg
--after insert on compra
--for each row
--execute procedure func_alerta_compra();

--funcion para comprobar si una tarjeta esta vencida recibe como parametro el campo validahasta
create or replace function verificar_vigencia(fecha_vencimiento char(6)) returns boolean as $$
declare
    fecha_actual_mes int :=cast(extract(month from current_date) as int); --extrae el mes de la fecha actual
    fecha_actual_año int :=cast(extract(year from current_date)  as int); --extrae el año de la fecha actual
    fecha_tarjeta_mes int:=cast(substr(fecha_vencimiento, 5, 2)  as int); --extrae el mes de la fecha de vencimiento de la tarjeta
    fecha_tarjeta_año int:=cast(substr(fecha_vencimiento, 1, 4)  as int); --extrae el año de la fecha de vencimiento de la tarjeta
begin
    insert into prueba values(fecha_actual_año,fecha_actual_mes,fecha_tarjeta_año,fecha_tarjeta_mes);
        if ((fecha_tarjeta_mes <= fecha_actual_mes and fecha_tarjeta_año <= fecha_actual_año) or fecha_tarjeta_año < fecha_actual_año) then
            return false;
        end if;
return true;
end;
$$ language plpgsql;




\c postgres
