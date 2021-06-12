drop database if exists basedatos;
create database basedatos;

\c basedatos

create table compra(
    nrooperacion serial,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(8,2),
    pagado  boolean
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

create table rechazo(
    nrorechazo  serial,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(8,2),
    motivo  text
);

insert into tarjeta values('4449942525596585', 7, '202010', '202509', '552', 120000.00, 'vigente');
insert into tarjeta values('4929028998516745', 8, '201610', '202109', '412', 110000.00, 'suspendida');
insert into tarjeta values('4916558526474988', 9, '201604', '202103', '633', 65000.00, 'anulada');--vencida

create or replace function autorizar_compra(nro_tarjeta char(16), cod_seguridad char(4), nro_comercio int, p_monto decimal(8,2)) returns boolean as $$
declare
    fecha_actual timestamp := current_timestamp(0);
    tarjeta record;
    monto_total decimal:= p_monto;
begin

    if ((SELECT count(*) FROM compra where nrotarjeta = nro_tarjeta ) > 0) then --verifico que exista alguna compra realizada por la tarjeta pasada como parametro
        monto_total := monto_total + (select sum(monto) from compra where nrotarjeta = nro_tarjeta); --sumo el total de las compras realizas por esa tarjeta mas la nueva compra
    end if;
    
    select * into tarjeta from tarjeta where nrotarjeta = nro_tarjeta;
    if  not found then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tarjeta, nro_comercio, fecha_actual, p_monto, 'tarjeta no valida o no vigente');
        return false;
    
    elsif cod_seguridad != tarjeta.codseguridad then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tarjeta, nro_comercio, fecha_actual, p_monto, 'codigo de seguridad invalido');
        return false;
    
    elsif (monto_total > tarjeta.limitecompra) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tarjeta, nro_comercio, fecha_actual, p_monto, 'supera limite de tarjeta');
        return false;
    
    elsif (select verificar_vigencia((tarjeta.validahasta))) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tarjeta, nro_comercio, fecha_actual, p_monto, 'plazo de vigencia expirado');
        return false;

    elsif 'suspendida' = (tarjeta.estado) then
        insert into rechazo (nrotarjeta, nrocomercio, fecha, monto, motivo) values(nro_tarjeta, nro_comercio, fecha_actual, p_monto, 'la tarjeta se encuentra suspendida');
        return false;

    else
        --se autoriza la compra
        insert into compra (nrotarjeta, nrocomercio, fecha, monto, pagado) values(nro_tarjeta, nro_comercio, fecha_actual, p_monto, true);
        return true;
    end if;
end;
$$ language plpgsql;

-- --funcion para comprobar si una tarjeta esta vencida recibe como parametro el campo validahasta
create or replace function verificar_vigencia(fecha_vencimiento char(6)) returns boolean as $$
declare
     fecha_actual date :=to_date(to_char(current_date,'YYYYMM'),'YYYYMM'); --extrae el mes de la fecha actual
     fecha_tarjeta date:=to_date(fecha_vencimiento, 'YYYYMM'); --extrae el mes de la fecha de vencimiento de la tarjeta

begin
     if (fecha_tarjeta <= fecha_actual) then
        return true;
     end if;
return false;
end;
$$ language plpgsql;

select autorizar_compra('4916558520474988','633',1,17000.00); --tarjeta no existe                        f
select autorizar_compra('4449942525596585','411',2,12000.00); --tarjeta mal codigo de seguridad          f
select autorizar_compra('4449942525596585','552',3,120000.00); --compra autorizada                       t    
select autorizar_compra('4916558526474988','633',4,3000.00); --tarjeta vencida                          f
select autorizar_compra('4929028998516745','412',5,5000.00); --tarjeta suspendida                       f
select autorizar_compra('4449942525596585','552',6,10000.00); --compra supera el limite de la tarjeta    f

select * from compra;
select * from rechazo;




-- \c postgres