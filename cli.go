//por ahora, para su correcto funcionamiento, la base de datos debe estar vacia, solo creada y sin conectarla

package main

//Importo paquetes
import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/lib/pq"
)

//main----------------------------------------------------------------------------------------------------
func main() {

	var opcion_elegida int //numero que elegira el usuario para ejecutar una opcion

	mostrar_opciones()

	fmt.Scan(&opcion_elegida)

	ejecutar_opcion(opcion_elegida)

}

//funcion que se llama desde el main para mostrar todas las opciones del CLI-------------------------------
func mostrar_opciones() {

	fmt.Println("\n-------------------------------\nElija una opcion para ejecutar:")
	fmt.Println("1- Crear base de datos")
	fmt.Println("2- Crear tablas")
	fmt.Println("3- Ingresar datos a las tablas")
	fmt.Println("4- Crear funciones")
	fmt.Println("5- Realizar compras")
}

//funcion que detecta la opción elegida a ejecutar---------------------------------------------------------
func ejecutar_opcion(opcion_elegida int) {

	fmt.Printf("La opcion elegida fue %v ", opcion_elegida) //linea solo de prueba para ver que funcione

	if opcion_elegida == 1 {
		crear_bdd()
		conectar_con_bdd()

	} else if opcion_elegida == 2 {

		crear_tablas()

	} else if opcion_elegida == 4 {

		crear_todas_las_funciones()

	} else if opcion_elegida == 5 {

		realizar_compras()

	} else {
			
		fmt.Println("Error, ingresa nuevamente")	
			
	}
	

	main() //llamo de vuelta al main para seguir con las opciones. corregir despues

}

//funcion para crear la base de datos----------------------------------------------------------------------

func crear_bdd() {
	//conectamos con postgres
	db, err := sql.Open("postgres", "user=postgres host=localhost dbname=postgres sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	//creamos nuestra base de datos
	_, err = db.Exec(`drop database if exists tarjetasdecredito`)
	if err != nil {
		log.Fatal(err)
	}
	_, err = db.Exec(`create database tarjetasdecredito`)
	if err != nil {
		log.Fatal(err)
	}

}

//funcion para conectar con nuestra bdd --------------------------------------------------------

func conectar_con_bdd() *sql.DB {
	//conectanos con nuestra base de datos
	db, err := sql.Open("postgres", "user=postgres host=localhost dbname=basedatos sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("\n### Base de datos conectada correctamente ###\n")
	return db
}

//funcion para crear las tablas-----------------------------------------------------------------------------
//Lo primero que hace es llamar a la funcion para conectar con nuestra bdd y lo guarda en la variable db
//después crea las tablas (falta completar las demás, solo hice uno de prueba)
//luego chequea los errores
//por ultimo cierra la conexion con la base (esto debe hacerse en funcion aparte porque debe permanecer abierta

func crear_tablas() {

	db := conectar_con_bdd() // conectamos a nuestra base de datos
	defer db.Close()         // alterminar de ejecutar todo lo que esta en el cuerpo de esta funcion se cierra la bdd hay que hacer esto
	// en cada funcion que creemos.
	_, err := db.Exec(`create table cliente(nroCliente int, nombre text, apellido text, domicilio text, telefono char(12));`)

	if err != nil {
		log.Fatal(err)
	}

	//hace falta aqui una funcion que cree las pk y fk

	fmt.Printf("\n### Tablas creadas ###\n")
}

//Inserts----------------------------------------------------------------------------------------------------
func llenar_tablas() {

	db := conectar_con_bdd()
	defer db.Close()

	_, err := db.Exec(`insert into cliente values(1,'Daniela Anabel','Oviedo','San Martin 3814','541130569988')`)

	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("\n### Inserts creados###\n")
}





//funcion que llama a todas las funciones de sql para que se creen y se guarden en la base de datos (completar)-----------
func crear_todas_las_funciones(){
	
	crear_funcion_autorizar_compra()
	crear_funcion_realizar_compras()
	crear_verificar_vigencia()
	crear_genera_resumen()
	crear_funcierre()
	
	
}


//Funcion funcierre que se guarda en la base de datos---------------------------------------------------------------------

func crear_funcierre(){
	
		db := conectar_con_bdd()
		
		_,err := db.Exec(`create or replace function funcierre() returns void as $$
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
$$ language plpgsql;`)
		
		if err != nil{
				log.Fatal(err)
		}
		
}


//Creo la funcion autorizar_compra que se va a guardar en la base de datos--------------------------------------------------------------------
func crear_funcion_autorizar_compra(){
	
	db := conectar_con_bdd()
	
	_,err := db.Exec(`create or replace function autorizar_compra(nro_tarjeta char(16), cod_seguridad char(4), nro_comercio int, p_monto decimal(8,2)) returns boolean as $$
declare
    fecha_actual timestamp := current_timestamp(0);
    tarjeta record;
    monto_total decimal:= p_monto;
begin

    if ((select count(*) from compra where nrotarjeta = nro_tarjeta ) > 0) then 
        monto_total := monto_total + (select sum(monto) from compra where nrotarjeta = nro_tarjeta); 
    end if;
    
    select * into tarjeta from tarjeta where nrotarjeta = nro_tarjeta;
    if  not found then --si no existe la tarjeta
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
$$ language plpgsql;`)

if err != nil{
		log.Fatal(err)
}

	fmt.Println("funcion creada")

	
}


//Funcion para que recorre la tabla consumo y autoriza la compra ----------------------------------------
//Esta funcion se guarda en la base de datos
func crear_funcion_realizar_compras(){
		
		db := conectar_con_bdd()
		
		_,err := db.Exec(`create or replace function realizar_compras() returns void as $$
declare
	fila record;
begin
	for fila in select * from consumo loop
		perform autorizar_compra(fila.nrotarjeta, fila.codseguridad, fila.nrocomercio, fila.monto);
	end loop;	
	return;
end;
$$ language plpgsql;`)
	
	if err != nil{
			log.Fatal(err)
	}

}

//Funcion genera_resumen que se guarda en la base de datos-----------------------------------------------------------------

func crear_genera_resumen(){
	
	db := conectar_con_bdd()
	
	_, err := db.Exec(`create or replace function genera_resumen(num_cliente int, periodo char(8)) returns void as $$
declare
    dato_cliente record;
    tarjetacliente  record;
    compra_cliente record;
    dato_cierre record;
    compra_comercio record;
    num_periodo int := cast (periodo as int);
    fila record;
    filap record;
    filas record;
    filat record;
    filac record;
    filaz record;
    total decimal (8,2);
    nresumen int;
    i int :=1;
    j int :=1;
begin

    --Se guardan datos del cliente 
    for dato_cliente in select * from cliente loop
        if (num_cliente = (select dato_cliente.nrocliente)) then
            dato_cliente.nrocliente = nrocliente,
            dato_cliente.nombre =nombre;
            dato_cliente.apellido =apellido,
            dato_cliente.domicilio =domicilio;
            dato_cliente.telefono = telefono;
        end if;
    end loop;

    --Se guardan las tarjetas del cliente
    for tarjetacliente in select * from tarjeta loop
        if (num_cliente = (select nrocliente from tarjeta)) then
        --if (num_cliente = tarjeta.nrocliente) then
            tarjetacliente.nrotarjeta =nrotarjeta;
            tarjetacliente.nrocliente =nrocliente;
        end if;
    end loop;

    --Se guardan los datos de cada tarjeta 
    for dato_cierre in select * from cierre loop
        for fila in select * from tarjetacliente loop
            if (terminacion = cast (substr(tarjetacliente.nrotarjeta,length(tarjetacliente.nrotarjeta),length(nombre_lugar)) as integer)) then
                dato_cierre.nrotarjeta = tarjetacliente.nrotarjeta;
                dato_cierre.año =año;
                dato_cierre.mes =mes;
                dato_cierre.terminacion =terminacion;
                dato_cierre.fechainicio =fechainicio;
                dato_cierre.fechacierre =fechacierre;
                dato_cierre.fechavto =fechavto;
            end if;
        end loop;
    end loop;

    --Se guardan las compras
    for compra_cliente in select * from compra loop
        for filas in select * from dato_cierre loop
            if (dato_cierre.nrotarjeta = compra.nrotarjeta AND ( (
                    extract(month FROM fecha)= num_periodo AND extract(day FROM fecha)<27) 
                    OR (extract(month FROM fecha)= num_periodo + 1 AND extract(day FROM fecha)>28) )) then
                compra_cliente.nrotarjeta =dato_cierre.nrotarjeta;
                compra_cliente.nrocomercio =nrocomercio;
                compra_cliente.fecha =fecha,
                compra_cliente.monto =monto;
                compra_cliente.pagado =pagado;
        end if;
        end loop;
    end loop;

    --SE guardan los nombres del comercio
    for compra_comercio in select * from comercio loop
        for filat in select * from compra_cliente loop
            if ((comercio.nrocomercio = compra_cliente.nrocomercio) AND (NOT compra_cliente)) then
                compra_comercio.nrotarjeta = compra_cliente.nrotarjeta;
                compra_comercio.nombre =comercio.nombre;
                compra_comercio.fecha =compra_cliente.fecha;
                compra_comercio.monto =compra_cliente.monto;
            end if;
        end loop;
    end loop;

    for total in select compra_comercio.monto from compra_comercio loop
        total := total + compra_comercio.monto;
    end loop;

    --Inserta los datos en la tabla cabecera y detalle
    for filac in select * from dato_cliente loop
        for filaz in select * from dato_cierre loop
            insert into cabecera (nombre, apellido, domicilio, nrotarjeta, desde, hasta, vence, total)
                values (dato_cliente.nombre, dato_cliente.apellido, dato_cliente.direccion,  
                dato_cierre.nrotarjeta, dato_cierre.fechainicio, dato_cierre.fechacierre, dato_cierre.fechavto,
                total
                --select sum (compra_comercio.monto) from compra_comercio
            );
            nresumen := cabecera.nroresumen;
            for filap in select * from compras_comercio loop
                if (dato_cierre.nrotarjeta = compra_comercio.nrotarjeta) then
                    insert into detalle values (nresumen, i, fecha, compra_comercio.fecha, compra_comercio.nombre, 
                    compra_comercio.monto
                    );
                    i := i+1;
                end if;
            end loop;
        end loop;
    end loop;


end;
$$ language plpgsql;`)
	
	if err != nil{
			log.Fatal(err)
	}
	
}

//Funcion verificar_vigencia que se guarda en la base de datos-------------------------------------------------------------

func crear_verificar_vigencia(){
	
	db := conectar_con_bdd()
	
	_,err := db.Exec(`create or replace function verificar_vigencia(fecha_vencimiento char(6)) returns boolean as $$
declare
     fecha_actual date :=to_date(to_char(current_date,'YYYYMM'),'YYYYMM'); 
     fecha_tarjeta date:=to_date(fecha_vencimiento, 'YYYYMM'); 
begin
     if (fecha_tarjeta <= fecha_actual) then 
        return true;
     end if;
return false;
end;
$$ language plpgsql;`)
	
	if err != nil {
			log.Fatal(err)
	}
	
}


//Funcion que llama a la funcion de realizar compras que esta en la base de datos---------------------------
func realizar_compras(){

	db := conectar_con_bdd()
	_,err := db.Exec(`select realizar_compras()`)
	
	if err != nil {
		log.Fatal(err)
	}
	
}

