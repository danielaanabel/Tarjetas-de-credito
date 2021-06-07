//por ahora, para su correcto funcionamiento, la base de datos debe estar vacia, solo creada y sin conectarla

package main

//Importo paquetes
import (

	"database/sql"
	"fmt"
	_"github.com/lib/pq"
	"log"
	
)
	
	
	
//main----------------------------------------------------------------------------------------------------	
func main() {
	
	var opcion_elegida int     //numero que elegira el usuario para ejecutar una opcion
	
	mostrar_opciones()
	
	fmt.Scan(&opcion_elegida)
	
	ejecutar_opcion(opcion_elegida)
	
}	



//funcion que se llama desde el main para mostrar todas las opciones del CLI-------------------------------
func mostrar_opciones() {
	
	fmt.Println("\n-------------------------------")
	fmt.Println("Elija una opcion para ejecutar:\n")
	fmt.Println("1- Conectar con base de datos")
	fmt.Println("2- Crear tablas")
	fmt.Println("3- Ingresar datos a las tablas")
	fmt.Println("4- Cerrar conexion con la base")	
	
}	



//funcion que detecta la funcion que hay que hacer---------------------------------------------------------	
func ejecutar_opcion(opcion_elegida int) {
	
	fmt.Printf("La opcion elegida fue %v " , opcion_elegida) //linea solo de prueba para ver que funcione
	
	if opcion_elegida == 1 {
		
			conectar_con_bdd()
		
	} else if opcion_elegida == 2 {
		
			crear_tablas()
		
	} else if opcion_elegida == 3 {
		
			crear_inserts()
		
	} else {
	
		fmt.Println("Error, ingresa nuevamente")
		
	}
	
	main()		//llamo de vuelta al main para seguir con las opciones. corregir despues
	
}	

//funcion para crear la base de datos----------------------------------------------------------------------


	//hace falta esta funcion?






//funcion para conectar con la base de datos creada--------------------------------------------------------	
	//se conecta con la base, la guarda en la variable db y la retorna para su uso en otras funciones
	// *sql.DB es el tipo que devuelve (me lo sugeria un error que me salio)
func conectar_con_bdd() *sql.DB {
	
	db,err := sql.Open("postgres", "user=postgres host=localhost dbname=basedatos sslmode=disable")
	
	if err != nil {
		log.Fatal(err)
	}
	
	//defer db.Close()   //crear funcion para cerrar conexion con la base de datos
	
	return db
}	




//funcion para crear las tablas-----------------------------------------------------------------------------
	//Lo primero que hace es llamar a la funcion para conectar con la bdd y lo guarda en la variable db
	//después crea las tablas (falta completar las demás, solo hice uno de prueba)
	//luego chequea los errores
	//por ultimo cierra la conexion con la base (esto debe hacerse en funcion aparte porque debe permanecer abierta
func crear_tablas(){
	
		db := conectar_con_bdd()
		
		_,err := db.Exec("create table cliente(nroCliente int, nombre text, apellido text, domicilio text, telefono char(12));")
		
		if err != nil {
			log.Fatal(err)
		}
		
		//hace falta aqui una funcion que cree las pk y fk
		
		defer db.Close()	
		
		fmt.Printf("\n### Tablas creadas ###\n")
}




//Inserts----------------------------------------------------------------------------------------------------
func crear_inserts() {
	
		db := conectar_con_bdd()
		
		_,err := db.Exec("insert into cliente values(1,'Daniela Anabel','Oviedo','San Martin 3814','541130569988');")
		
		if err != nil {
			log.Fatal(err)
		}
		
		defer db.Close()
		
		fmt.Printf("\n### Inserts creados###\n")
	
}
