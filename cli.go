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

//Funcion que llama a la funcion de realizar compras que esta en la base de datos---------------------------
func realizar_compras(){

	db := conectar_con_bdd()
	_,err := db.Exec(`select realizar_compras()`)
	
	if err != nil {
		log.Fatal(err)
	}
	
}

