# ----------------------Datos---------------------- #

# Inputs
set Paradas;
set Parking;
set Colegio;

# Set auxiliar
set Estaciones := Parking union Paradas union Colegio;

param Distancias{Estaciones,Estaciones};
param MaximoBuses;
param CapacidadBuses;
param PersonasPorParada{Estaciones};

# Parámetros y sets auxiliares
set SinParking := Paradas union Colegio; 
set SinColegio := Parking union Paradas;
set Enlaces := {(i, j) in Estaciones cross Estaciones}; # enlaces sin reiteración



# -------------Variables de decisión------------- #

var conexiones{(i, j) in Enlaces}, binary;
var flujos{(i, j) in Enlaces} >= 0; # flujos sin reiteración



# ---------------Función objetivo--------------- #

# precio de un autobus es 120€
# precio de un bus en un enlace es 5€/km

minimize Profit: 5 * sum{(i, j) in Enlaces} Distancias[i, j] * conexiones[i, j] + 120 * sum{p in Paradas} conexiones["Parking", p];


# ----------------Restricciones---------------- #

# Restricciones de matriz de rutas 
s.t. enlaceSalida{i in Paradas}:  sum{j in SinParking : i != j } conexiones[i,j] = 1;
s.t. enlaceEntrada{j in Paradas}: sum{i in SinColegio : i != j} conexiones[i,j] = 1;
s.t. maximoBuses: sum{j in Estaciones} conexiones["Parking",j] <= MaximoBuses;
s.t. diferenciaBusesParkCole: sum{j in Paradas} conexiones["Parking", j] - sum{i in Paradas} conexiones[i,"Colegio"] = 0;

# Restricciones de capacidad
s.t. flujoEnParada{i in Paradas}: sum{j in SinColegio : i != j} flujos[j, i] + PersonasPorParada[i] = sum{j in SinParking : i != j} flujos[i,j];
s.t. flujoEnEnlace{i in Estaciones, j in Estaciones : i != j}: flujos[i, j] <=  conexiones[i,j] * CapacidadBuses;

# -----------------Resolver----------------- #

solve;

end;
