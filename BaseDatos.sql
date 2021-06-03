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
    nrorechazo  int,
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


insert into tarjeta values('4286283215095190', 1, '201709', '202208', '114', 45000.00, 'vigente');
insert into tarjeta values('4532449515464319', 2, '202001', '202412', '881', 30000.00, 'vigente');
insert into tarjeta values('4716905901199213', 3, '202108', '202607', '311', 150000.00, 'vigente');
insert into tarjeta values('4539760286740064', 4, '202204', '202703', '553', 35000.00, 'vigente');
insert into tarjeta values('4916197097056062', 5, '202010', '202509', '103', 45000.00, 'anulada');
insert into tarjeta values('4532157860627139', 6, '202004', '202503', '802', 42000.00, 'anulada');
insert into tarjeta values('4449942525596585', 7, '202010', '202509', '552', 120000.00, 'vigente');
insert into tarjeta values('4929028998516745', 8, '201610', '202109', '412', 110000.00, 'suspendida');
insert into tarjeta values('4916558526474988', 9, '201604', '202103', '633', 65000.00, 'vencida');
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

\c postgres



