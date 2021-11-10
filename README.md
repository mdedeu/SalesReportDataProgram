# Integrantes del TP
- [Florencia Chao](https://github.com/user/fchao)
- [Marcos Dedeu](https://github.com/user/mdedeu) 
- [Ariadna Fernández Truglia](https://github.com/user/arfernandez2000)
- [Hernán Finucci](https://github.com/user/hfinucci)


# Prerequisitos:
Se utilizará pampero para la prueba del TP. <br/>
El único requisito es tener el archivo marketing_campaign.csv cargado a Pampero.<br/>

# Instrucciones
## Primer Paso:

Ubicado en pampero, ejecutar en linea de comando la siguiente instrucción para crear las tablas, funciones y triggers necesarios:<br/>
	 ``` psql -h bd1.it.itba.edu.ar -U username -f functions.sql PROOF```
Puede corrobar que haya tenido éxito revisando que existan todas las tablas de la consigna y las funciones y triggers explayados en el archivo functions.sql.<br/>

## Segundo Paso:
Luego, debemos abrir la conexión con la BD. Para ello, ejecutar en línea de comando la siguiente instruccion para ingresar a la base de datos:<br/>
	 ```psql -h bd1.itba.edu.ar -U username PROOF```

## Tercer Paso:
 Una vez cargada la terminal para utilizar sobre la BD,ejecutar en linea de comando la siguiente instruccion para cargar los datos:<br/><br/>
 	```\copy intermedia(id, year_birth, education, marital_status, income, kidhome, teenhome, dt_customer, recency, mnt_wines, mnt_fruits, mnt_meat, mnt_fish, mnt_sweet, num_deals_purchases, num_web_purchases, num_catalog_purchases, num_stores_purchases)  FROM marketing_campaign.csv delimiter ',' csv header ``` 
