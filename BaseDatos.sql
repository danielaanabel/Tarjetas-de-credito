drop database if exists BaseDatos;
create database BaseDatos;

\c BaseDatos

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
    validadesde char(16),
    validahasta char(16),
    codseguridad char(4),
    limitecompra decimal(8,2),
    estado  char(10),
);

create table comercio(
    nrocomercio int,
    nombre      text,
    domicilio   text,
    codigopostal char(8),
    telefono    char(12),
);

create table compra(
    nrooperacion int,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(7,2),
    pagado  boolean,
);

create table rechazo(
    nrorechazo  int,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(7,2),
    motivo  text,
);

create table cierre(
    año int,
    mes int,
    terminacion int,
    fechainicio date,
    fechacierre date,
    fechavto    date,
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
    total   decimal(8,2),
);

create table detalle(
    nroresumen  int,
    nrolinea    int,
    fecha   date,
    nombrecomercio text,
    monto   decimal(7,2),
);

create table alerta(
    nroalerta   int,
    nrotarjeta  char(16),
    fecha   timestamp,
    nrorechazo  int,
    codalerta   int,
    descripcion text,
);

create table consumo(
    nrotarjeta  char(16),
    codseguridad char(4),
    nrocomercio int,
    monto   decimal(7,2),
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

alter table cabecera add constraint cabezera_nrotarjeta_fk foreign key (nrotarjeta)  references tarjeta(nrotarjeta);

alter table detalle  add constraint detalle_nroresumen_fk  foreign key (nroresumen)  references cabecera(nroresumen);

alter table alerta   add constraint alerta_nrotarjeta_fk   foreign key (nrotarjeta)  references tarjeta(nrotarjeta);
alter table alerta   add constraint alerta_nrorechazo_fk   foreign key (nrorechazo)  references rechazo(nrorechazo);

alter table consumo  add constraint consumo_nrotarjeta_fk  foreign key (nrotarjeta)  references tarjeta(nrotarjeta);
alter table consumo  add constraint consumo_nrocomercio_fk foreign key (nrocomercio) references comercio(nrocomercio);

\c postgres
