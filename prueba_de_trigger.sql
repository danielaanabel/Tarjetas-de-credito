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
    nrooperacion serial,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(8,2),
    pagado  boolean
);

create table rechazo(
    nrorechazo  serial,
    nrotarjeta  char(16),
    nrocomercio int,
    fecha   timestamp,
    monto   decimal(8,2),
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
    nroresumen  serial,
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
    nroresumen  serial,
    nrolinea    int,
    fecha   date,
    nombrecomercio text,
    monto   decimal(8,2)
);

create table alerta(
    nroalerta   serial,
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
    monto   decimal(8,2)
);

create table prueba(
    total_sumado decimal(8,2)
);

insert into tarjeta values('4449942525596585', 7, '202010', '202509', '552', 120000.00, 'vigente');
insert into tarjeta values('4929028998516745', 8, '201610', '202109', '412', 110000.00, 'suspendida');
insert into tarjeta values('4916558526474988', 9, '201604', '202103', '633', 65000.00, 'anulada');--vencida
insert into tarjeta values('4286283215095190', 1, '201709', '202208', '114', 45000.00, 'vigente');
insert into tarjeta values('4532449515464319', 2, '202001', '202412', '881', 30000.00, 'vigente');
insert into tarjeta values('4716905901199213', 3, '202108', '202607', '311', 150000.00, 'vigente');
insert into tarjeta values('4539760286740064', 4, '202204', '202703', '553', 35000.00, 'vigente');


insert into comercio values(1, 'Coto', 'Belgrano 960', 'B1619JHU','034844458867');
insert into comercio values(2, 'Sodimac','Constituyentes 1370','B1619JHU','112658423658');
insert into comercio values(3, 'Buen Gusto', 'Av. Libertador 3072', 'C1245YTD','541126598965');
insert into comercio values(4, 'Cafeteria Victor', 'Juan Gutierrez 1150', 'B1613GAE', '541178451245');
insert into comercio values(5, 'Libreria Alondra', 'Mateo Churich 130', 'B1619JGB', '541125584518');
insert into comercio values(6, 'Carrefour', 'Los Andes 458', 'B1608OKL', '541126154879');
insert into comercio values(7, 'El Boulevard', 'General Peron 377', 'B1610HGU', '541128964712');
insert into comercio values(8, 'Rapanui', 'Juan Domingo Peron 1974', 'C1456NSM', '541126597841');
insert into comercio values(9, 'Ñoquis Artesanales', 'Balcarce 50', 'C1064KCF', '541143443600');
insert into comercio values(10, 'McDonalds', 'Hipolito Yrigoyen 267', 'B1610LPN','541126455468');


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

---funciones del trigger rechazo
create or replace function func_alerta_rechazo() returns trigger as $$
declare
    undia interval := '24:00:00';
    i record;
begin
    insert into alerta (nrotarjeta,fecha ,nrorechazo, codalerta, descripcion) 
    values(new.nrotarjeta, new.fecha, new.nrorechazo, 0, 'se produjo un rechazo'); --cualquier tipo de rechazo se guarda

    for i in select * from rechazo where nrotarjeta = new.nrotarjeta and motivo = 'supera limite de tarjeta' loop 
        if (new.fecha - i.fecha) < undia then --si hay mas de un rechazo por superar el limite de una tarjeta esta se suspende y se guarda el rechazo
            update tarjeta set estado = 'suspendida' where nrotarjeta = new.nrotarjeta;
            
            insert into alerta (nrotarjeta,fecha ,nrorechazo, codalerta, descripcion) 
            values(new.nrotarjeta, new.fecha, new.nrorechazo, 32, 'supero el limite de compra mas una vez');
        end if; 
    end loop;   
    return new;
end;
$$ language plpgsql;

create trigger rechazo_trg
before insert on rechazo
for each row
execute procedure func_alerta_rechazo();


create function func_alerta_compra() returns trigger as $$
declare
    unminuto interval := '00:01:00';
    cincominutos interval := '00:05:00';

    i record;
    j record;

begin
    if (select count(*) from compra where nrotarjeta = new.nrotarjeta) > 1 then
            
        for i in select * from compra where nrotarjeta = new.nrotarjeta and nrocomercio in 
            (select nrocomercio from comercio where nrocomercio != new.nrocomercio and codigopostal = 
             (select codigopostal from comercio where nrocomercio = new.nrocomercio)) loop--2 compras en menos de un minuto en comercios distintos mismo CP

            if (new.fecha - i.fecha) <= unminuto then
            
                insert into alerta (nrotarjeta,fecha ,nrorechazo, codalerta, descripcion) 
                values(new.nrotarjeta, new.fecha, null, 1 ,'dos compras dentro del distrito en menos de un minuto'); 
         
            end if;
        end loop;

               
        for j in select fecha from compra where nrotarjeta = new.nrotarjeta and nrocomercio in
            (select nrocomercio from comercio where codigopostal != 
             (select codigopostal from comercio where nrocomercio = new.nrocomercio)) loop --2 compras en menos de 5 minutos en comercios distintos y distinto CP

            if (new.fecha - j.fecha) <= cincominutos then

                insert into alerta (nrotarjeta,fecha ,nrorechazo, codalerta, descripcion) 
                values(new.nrotarjeta, new.fecha, null, 5 ,'dos compras fuera del distrito en menos de 5 minutos');
            
            end if;
        end loop;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger compra_trg
after insert on compra
for each row
execute procedure func_alerta_compra();




select autorizar_compra('4916558520474988','633',1,17000.00); --tarjeta no existe                        f
select autorizar_compra('4449942525596585','411',2,12000.00); --tarjeta mal codigo de seguridad          f
select autorizar_compra('4449942525596585','552',3,120000.00); --compra autorizada                       t    
select autorizar_compra('4916558526474988','633',4,3000.00); --tarjeta vencida                          f
select autorizar_compra('4929028998516745','412',5,5000.00); --tarjeta suspendida                       f
select autorizar_compra('4449942525596585','552',6,10000.00); --compra supera el limite de la tarjeta    f
select autorizar_compra('4449942525596585','552',6,10000.00); --compra supera el limite de la tarjeta    f segunda vez rechazada por exceso del limite

select autorizar_compra('4286283215095190','114',1,1000.00);
select autorizar_compra('4286283215095190','114',2,1000.00);--2 compras en menos de un minuto en comercios distintos mismo CP

select autorizar_compra('4539760286740064','553',7,500.00);
--agregar espera de 5 minutos creo que se hace en GO
select autorizar_compra('4539760286740064','553',8,1300.00);--2 compras en menos de 5 minutos en comercios distintos y distinto CP

select * from compra;
select * from rechazo;


select * from alerta;



