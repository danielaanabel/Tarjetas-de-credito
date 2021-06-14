--borrado pk
alter table cliente drop constraint cliente_pk;
alter table tarjeta drop constraint tarjeta_pk;
alter table comercio drop constraint comercio_pk;
alter table compra drop constraint compra_pk;
alter table rechazo drop constraint rechazo_pk;
alter table cierre drop constraint cierre_pk;
alter table cabecera drop constraint cabecera_pk;
alter table detalle drop constraint detalle_pk;
alter table alerta drop constraint alerta_pk;
--borrado fk
alter table tarjeta drop constraint tarjeta_nrocliente_fk;
alter table compra drop constraint compra_nrotarjeta_fk;
alter table compra drop constraint compra_nrocomercio_fk;
alter table rechazo drop constraint rechazo_nrotarjeta_fk;
alter table rechazo drop constraint rechazo_nrocomercio_fk;
alter table cabecera drop constraint cabecera_nrotarjeta_fk;
alter table detalle drop constraint detalle_nroresumen_fk;
alter table alerta drop constraint alerta_nrotarjeta_fk;
alter table alerta drop constraint alerta_nrorechazo_fk;
alter table consumo drop constraint consumo_nrotarjeta_fk;
alter table consumo drop constraint consumo_nrocomercio_fk;










