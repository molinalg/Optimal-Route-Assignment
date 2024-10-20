# ----------------------Datos---------------------- #

# Inputs
set Paradas;
set Parking;
set Colegio;
set Familias;
set Alumnos;

# Parámetros y sets auxiliares
set Estaciones := Parking union Paradas union Colegio;
set SinParking := Paradas union Colegio; 
set SinColegio := Parking union Paradas;
set Enlaces := {(i, j) in Estaciones cross Estaciones}; # enlaces sin reiteración

param Distancias{Estaciones,Estaciones};
param MaximoBuses;
param CapacidadBuses;
set FamiliasPorParada{Familias};
set MiembrosFamilias{Familias};


# -------------Variables de decisión------------- #

var conexiones{(i, j) in Enlaces}, binary;
var flujos{(i, j) in Enlaces} >= 0;
var asignar{(i,j) in Familias cross Estaciones}, binary;


# ---------------Función objetivo--------------- #

# precio de un autobus es 120€
# precio de un bus en un enlace es 5€/km

minimize Profit: 5 * sum{(i, j) in Enlaces} Distancias[i, j] * conexiones[i, j] + 120 * sum{p in Paradas} conexiones["Parking", p];

# ----------------Restricciones---------------- #

# Restricciones de matriz de rutas 
s.t. enlaceEntrada{i in Paradas}: sum{j in Estaciones : i != j} conexiones[i,j] <= 1;
s.t. enlaceSalida{i in Paradas}:  sum{j in Estaciones : i != j } conexiones[j,i] <= 1;
s.t. maximoBuses: sum{j in Paradas} conexiones[j,"Parking"] <= MaximoBuses;
s.t. diferenciaBusesParkingColegio: sum{i in Paradas} conexiones[i,"Parking"] - sum{i in Paradas} conexiones["Colegio",i] = 0;
s.t. entraYSale{i in Paradas}: sum{j in Estaciones} conexiones[j,i] - sum{j in Estaciones} conexiones[i,j] = 0;

# Restricciones de capacidad
s.t. flujoEnParada{i in Paradas}: sum{j in SinColegio : i != j} flujos[j, i] + sum{f in Familias}(asignar[f,i] * card(MiembrosFamilias[f])) = sum{j in SinParking : i != j} flujos[i,j]; /* entran + hay = salen */
s.t. flujoEnEnlace{i in Estaciones, j in Estaciones : i != j}: flujos[i, j] <=  conexiones[i,j] * CapacidadBuses;

# Restricciones de asignación
s.t. asignacionObligatoria{f in Familias}: sum{p in FamiliasPorParada[f]} asignar[f,p] = 1;


# -----------------Resolver----------------- #
solve;

end;
