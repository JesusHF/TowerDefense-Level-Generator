-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- INICIALIZACION ///////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
try(destroyDialog generadorTD) catch()

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- VARIABLES  /////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --

-- GENERALES
centroX = 0
centroY = 0
centroZ = 0

tamX = 10
tamY = 10

tamanoBloque = 10.0
altura= 2.0

-- Camino
sueloArray = #()
startX = 0
startY = 0
caminoRecto = 0
zonaPeligrosa = false
girarArriba = false
girarAbajo = false
	
--Torres
maxTorres = tamX*tamY/10
usingTowerAmount = true
nTorres = maxTorres/2 
porTorres = 50
randomPiezasT = false
	
--Decoracion
randomPiezasD = false
porDecoracion = 20
arboles = true
arbolesTriples = true
arbolesRosas = true
piedras = true
piedrasDobles = true

--Iluminacion
randomIluminacion = false
sceneShadows = true


-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- MODELOS //////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
suelo = sysInfo.currentdir + "\modelos\piezaSuelo.3ds"
linea = sysInfo.currentdir + "\modelos\piezaLinea.3ds"
giroLinea = sysInfo.currentdir + "\modelos\giroLinea.3ds"
rio = sysInfo.currentdir + "\modelos\piezaRio.3ds"
giroRio= sysInfo.currentdir + "\modelos\giroRio.3ds"
puente = sysInfo.currentdir + "\modelos\puente.3ds"

piedra = sysInfo.currentdir + "\modelos\piedra.3ds"
piedraDoble = sysInfo.currentdir + "\modelos\piedraDoble.3ds"
arbolRosa = sysInfo.currentdir + "\modelos\arbolRosa.3ds"
arbol = sysInfo.currentdir + "\modelos\arbol.3ds"
arbolTriple = sysInfo.currentdir + "\modelos\arbolTriple.3ds"

baseTorre1 = sysInfo.currentdir + "\modelos\\torres\baseTorre1.3ds"
baseTorre2 = sysInfo.currentdir + "\modelos\\torres\baseTorre2.3ds"
baseTorre3 = sysInfo.currentdir + "\modelos\\torres\baseTorre3.3ds"
baseTorre4 = sysInfo.currentdir + "\modelos\\torres\baseTorre4.3ds"
baseTorre5 = sysInfo.currentdir + "\modelos\\torres\baseTorre5.3ds"
baseTorre6 = sysInfo.currentdir + "\modelos\\torres\baseTorre6.3ds"
baseTorre7 = sysInfo.currentdir + "\modelos\\torres\baseTorre7.3ds"
basesT = #(baseTorre1, baseTorre2, baseTorre3, baseTorre4, baseTorre5, baseTorre6, baseTorre7)

cuerpoTorre1 = sysInfo.currentdir + "\modelos\\torres\cuerpoTorre1.3ds"
cuerpoTorre2 = sysInfo.currentdir + "\modelos\\torres\cuerpoTorre2.3ds"
cuerpoTorre3 = sysInfo.currentdir + "\modelos\\torres\cuerpoTorre3.3ds"
cuerpoTorre4 = sysInfo.currentdir + "\modelos\\torres\cuerpoTorre4.3ds"
cuerpoTorre5 = sysInfo.currentdir + "\modelos\\torres\cuerpoTorre5.3ds"
cuerpoTorre6 = sysInfo.currentdir + "\modelos\\torres\cuerpoTorre6.3ds"
cuerposT = #(cuerpoTorre1, cuerpoTorre2, cuerpoTorre3, cuerpoTorre4, cuerpoTorre5, cuerpoTorre6)

techoTorre1 = sysInfo.currentdir + "\modelos\\torres\\techoTorre1.3ds"
techoTorre2 = sysInfo.currentdir + "\modelos\\torres\\techoTorre2.3ds"
techoTorre3 = sysInfo.currentdir + "\modelos\\torres\\techoTorre3.3ds"
techoTorre4 = sysInfo.currentdir + "\modelos\\torres\\techoTorre4.3ds"
techoTorre5 = sysInfo.currentdir + "\modelos\\torres\\techoTorre5.3ds"
techoTorre6 = sysInfo.currentdir + "\modelos\\torres\\techoTorre6.3ds"
techoTorre7 = sysInfo.currentdir + "\modelos\\torres\\techoTorre7.3ds"
techoTorre8 = sysInfo.currentdir + "\modelos\\torres\\techoTorre8.3ds"
techoTorre9 = sysInfo.currentdir + "\modelos\\torres\\techoTorre9.3ds"
techosT = #(techoTorre1, techoTorre2, techoTorre3, techoTorre4, techoTorre5, techoTorre6, techoTorre7, techoTorre8, techoTorre9)

caminosPosibles = #(linea, giroLinea, puente)
riosPosibles = #(rio, giroRio)
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- FUNCIONEZ //////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
fn importModel nombreFichero = (
	if tamanoBloque == (5.0/3.0) then(
		importFile nombreFichero #noprompt using:importerPlugin.classes[1]
		$.pos = [centroX + tamanoBloque/2,centroY + tamanoBloque/2,centroZ + altura]
	)
	else if tamanoBloque == 5.0 then (
		importFile nombreFichero #noprompt using:importerPlugin.classes[1]
		scale $ [3,3,3]
		$.pos = [centroX + tamanoBloque/2,centroY + tamanoBloque/2,centroZ + altura]
	)
	else if tamanoBloque == 10.0 then (
		importFile nombreFichero #noprompt using:importerPlugin.classes[1]
		scale $ [6,6,6]
		$.pos = [centroX + tamanoBloque/2,centroY + tamanoBloque/2,centroZ + altura]
	)
	else (print "UNHANDLED ERROR OF BLOCK SIZE")
)

fn updateNTowers ptamX ptamY= (
	local areaG = ptamX * ptamY
	maxTorres = 9 + (areaG/100)
	if nTorres > maxTorres then (
		nTorres = maxTorres
	)
)

fn crearSuelo uselessParam = (
	sueloArray = #()
	for x= 1 to tamX do(
		append sueloArray #()
		for y=1 to tamY do(
			append sueloArray[x] #()
			
			importModel suelo
			local baseName = $.name
			$.name = uniquename (baseName as string)
			
			--mybox = box length:10 width:10 height:4
			--select mybox 
			$.name = uniquename ("suelo")
			sueloArray[x][y] = $.name
			
			move $ [(x-1) * tamanoBloque, (y-1) * tamanoBloque, 0]
			clearSelection()
		)
	)
)

--Empieza el camino
fn startCamino &actual &last &next = (
	local type = 1
	local maxX = tamX-2
	local maxY = tamY-2
	--se calcula el inicio
	if type == 0 then(
		startX = random 3 maxX
		startY = 1
		
		last = [startX, 0]
		actual = [startX, startY]
		next = [startX, 2]
	)
	else if type == 1 then (
		startX = 1
		startY = random 3 maxY

		last = [0, startY]
		actual = [startX, startY]
		next = [2, startY]
	)
	else if type == 2 then (
		startX = tamX
		startY = random 3 maxY
		
		last = [startX+1, startY]
		actual = [startX, startY]
		next = [startX-1, startY]
	)
	else if type == 3 then (
		startX = random 3 maxX
		startY = tamY
		
		last = [startX, startY+1]
		actual = [startX, startY]
		next = [startX, startY-1]
	)
	else (print "WRONG CALL FUNCTION")
	
	return type
	--se calcula el final
	--do (local type2 = random 0 3) while (type2 == type)
)

--Devuelve los limites del rio/nivel donde termina
fn getLimites type = (
	local limits = #(0, 0, 0, 0)
	if type == 0 then(
		limits = #(1, tamX, 1, tamY)
	)
	else if type == 1 then (
		limits = #(1, tamX, 1, tamY)
	)
	else if type == 2 then (
		limits = #(1, tamX, 1, tamY)
	)
	else if type == 3 then (
		limits = #(1, tamX, 1, tamY)
	)
	return limits
)

--Devuelve un entero que representa la posicion de cada coord
fn comparaPos vieja nueva = (
	if (vieja.x == nueva.x) then (
		if(vieja.y == nueva.y) then return -1
		if(nueva.y < vieja.y) then return 3
		if(nueva.y > vieja.y) then return 0
	)
	else if (vieja.y == nueva.y) then (
		if(nueva.x < vieja.x) then return 2
		if(nueva.x > vieja.x) then return 1
	)
)

fn posPorOpcion option nextP= (
	local next2return = [0,0]
	
	if(option == 0 and nextP.y<tamY) then next2return = [nextP.x, nextP.y+1]
	else if(option == 1) then next2return = [nextP.x+1, nextP.y]
	else if(option == 2) then next2return = [nextP.x-1, nextP.y]
	else if(option == 3 and nextP.y>1) then next2return = [nextP.x, nextP.y-1]
	else return nextP
	
	return next2return
)

--Importa el modelo necesario para el camino
fn getPiezaCamino last actual next = (
		local tipoLast = comparaPos last actual
	local tipoNext = comparaPos actual next
	
	--Linea recta
	if(tipoLast == tipoNext) then(
		importModel caminosPosibles[1]
		if(tipoLast == 0 or tipoLast == 3) then rotate $ (angleaxis 90 [0,0,1])
	)
	--Giro camino
	else(
		importModel caminosPosibles[2]
		
		if(tipoLast == 0) then (
			rotate $ (angleaxis -90 [0,0,1])
			if(tipoNext == 2) then rotate $ (angleaxis -90 [0,0,1])
		)
		else if (tipoLast == 1) then (
			rotate $ (angleaxis 90 [0,0,1])
			if(tipoNext == 3) then rotate $ (angleaxis 90 [0,0,1])
		)
		else if (tipoLast == 2 and tipoNext == 3) then rotate $ (angleaxis -90 [0,0,1])
		else if (tipoLast == 3 and tipoNext == 2) then rotate $ (angleaxis 90 [0,0,1])
	)

)

--Importa el modelo necesario para el rio
fn getPiezaRio last actual next = (
	local tipoLast = comparaPos last actual
	local tipoNext = comparaPos actual next
	
	--Linea recta
	if(tipoLast == tipoNext) then(
		importModel riosPosibles[1]
		if(tipoLast == 0 or tipoLast == 3) then rotate $ (angleaxis 90 [0,0,1])
	)
	--Giro rio
	else(
		importModel riosPosibles[2]
		print "posiciones"
		print ((last as string) + " " + (actual as string) + " " + (next as string))
		print "tipos"
		print ((tipoLast as string)+" "+(tipoNext as string))
		
		if(tipoLast == 0) then (
			rotate $ (angleaxis -90 [0,0,1])
			if(tipoNext == 2) then rotate $ (angleaxis -90 [0,0,1])
		)
		else if (tipoLast == 1) then (
			rotate $ (angleaxis 90 [0,0,1])
			if(tipoNext == 3) then rotate $ (angleaxis 90 [0,0,1])
		)
		else if (tipoLast == 2 and tipoNext == 3) then rotate $ (angleaxis -90 [0,0,1])
		else if (tipoLast == 3 and tipoNext == 2) then rotate $ (angleaxis 90 [0,0,1])
	)
)

--Devuelve la distancia trazando la direccion hasta que colisiona con algo
fn checkDirection lastP actualP = (
	local distancia = 0
	
	if (lastP.x == actualP.x) then(
		if (actualP.y > lastP.y) then (
			--en el caso de que la x sea igual y apunta hacia arriba
			for y = actualP.y to tamY do(
				distancia += 1
					
				--print sueloArray[actualP.x][y]
				if (findString sueloArray[actualP.x][y] "suelo" == undefined) then return distancia
			)
		)
		else (
			--en el caso de que la x sea igual y apunta hacia abajo
			local y = actualP.y
			while (y>1 and distancia<7) do(
				distancia += 1
				
				--print sueloArray[actualP.x][y]
				if (findString sueloArray[actualP.x][y] "suelo" == undefined) then return distancia
				y -= 1
			)
		)
	)
	else(
		if (actualP.x > lastP.x) then (
			--en el caso de que la y sea igual y apunta hacia la derecha
			for x = actualP.x to tamX do(
				distancia += 1
				
				--print sueloArray[x][actualP.y] 
				if (findString sueloArray[x][actualP.y] "suelo" == undefined) then return distancia
			)
		)
		else (
			--en el caso de que la y sea igual y apunta hacia la izquierda
			local x = actualP.x
			while (x>1 and distancia<7) do(
				distancia += 1
				
				--print sueloArray[x][actualP.y] 
				if (findString sueloArray[x][actualP.y] "suelo" == undefined) then return distancia
				x -= 1
			)
		)
	)
	return distancia
)

--Devuelve la posicion cardinal proxima al valor por parametro
fn getCardinal pactual plast = (
	ngiros -=1
	local var2return = [plast.x,plast.y]
	
	local possiblesRoutes = #()
	local ruta
	/*
	if (pactual.y == plast.y) then 
		possiblesRoutes = #([pactual.x, pactual.y+1], [pactual.x, pactual.y-1])
	else 
		possiblesRoutes = #([pactual.x-1, pactual.y],  [pactual.x+1, pactual.y])
	*/
	if (plast.y == pactual.y) then(
		possiblesRoutes = #([pactual.x-1, pactual.y], [pactual.x+1, pactual.y])
		ruta = possiblesRoutes[random 1 2]
	)
	else (
		possiblesRoutes = #([pactual.x, pactual.y-1], [pactual.x, pactual.y+1])
		ruta = possiblesRoutes[random 1 2]
	)
	local dist1 = checkDirection pactual possiblesRoutes[1]
	print ("RUTA1: "+(possiblesRoutes[1] as string)+ " " +(dist1 as string))
	
	local dist2 = checkDirection pactual possiblesRoutes[2]
	print ("RUTA2: "+(possiblesRoutes[2] as string)+ " " +(dist2 as string))
	
	
	if(dist1 > 7 and dist2>7) then(
		var2return = possiblesRoutes[random 1 2]
		caminoRecto = random 3 7
	)
	else if (dist1 > dist2) then(
		var2return = possiblesRoutes[1]
		
		local maxDist = 7
		if (dist1 < maxDist) then maxDist=dist1
		caminoRecto = random 3 maxDist-1
	)
	else (
		var2return = possiblesRoutes[2]
		
		local maxDist = 7
		if (dist2 < maxDist) then maxDist=dist2
		caminoRecto = random 3 maxDist-1
	)
	
	return var2return
)

--Actualiza los vectores de movimiento
fn updateRio limits &last &actual &next = (
	last = actual
	actual = next
	
	local opcion = comparaPos last actual
	
	--Se continua recto
	if (caminoRecto > 0) then (
		--print("Avanzo recto. CaminoRecto: "+(caminoRecto as String) )
		
		next = posPorOpcion opcion next
		caminoRecto -= 1
		
		if(next.x == limits[1] or next.x == limits[2] or next.y == limits[3] or next.y == limits[4]) then
			caminoRecto = 2
	)
	--Se elige giro
	else (
		local posibleNext = posPorOpcion opcion next
		if(posibleNext.x == limits[1] or posibleNext.x == limits[2] or posibleNext.y == limits[3] or posibleNext.y == limits[4]) then(
			--print "casi giro al final del mapa :D"
			next = posibleNext
			caminoRecto = 2
		)
		else (
			--print("Avanzo girando. CaminoRecto: "+(caminoRecto as String) )
			next = getCardinal actual last			
		)
	)
)

--Genera el rio
fn crearRio uselessParam = (
	local terminado = false
	caminoRecto = random 3 5
	ngiros = 2
	
	--se declaran las posiciones que se iran actualizando
	local lastpos = [0, 0]
	local actualpos = [0, 0]
	local nextpos = [0, 0]
	
	--se encuentra la posicion inicial del rio y se obtienen los limites
	local tipo = startCamino &actualpos &lastpos &nextpos
	local limites = getLimites tipo
	local endPrepared = false
	
	do(		
		--se recorre la matriz de nombres y se selecciona el actual
		local nombre = sueloArray[actualpos.x][actualpos.y]
		execute ("select $'"+ nombre + "'")
		
		--se comprueba que la casilla seleccionada sea una pieza de suelo
		if (findString $.name "suelo" > 0) then(
			local object2delete = $
			
			getPiezaRio lastpos actualpos nextpos
			local baseName = $.name
			
			$.pos = object2delete.pos
			$.name = uniquename (baseName as string)
			sueloArray[actualpos.x][actualpos.y] = $.name
			clearSelection()
			
			--print sueloArray
			delete object2delete
			
			updateRio limites &lastpos &actualpos &nextpos
			
			--print("Actual: "+(actualpos as String) + "Siguiente: "+(nextpos as String) )
			
			if (lastpos.x == limites[1] or lastpos.x == limites[2] or lastpos.y == limites[3] or lastpos.y == limites[4]) then(
				if (endPrepared) then
					terminado = true
				else endPrepared = true
			)
		)
		else(
			print "PIEZA INESPERADA: "
		)
	)while (not terminado)
)

fn updateCamino limits &last &actual &next = (
	last = actual
	actual = next
	
	local opcion = comparaPos last actual
	local posibleNext = posPorOpcion opcion next
	
	--Se continua recto
	if (caminoRecto > 0) then (
		print("Avanzo recto. CaminoRecto: "+(caminoRecto as String) )
		
		next = posibleNext
		caminoRecto -= 1
		
		if(next.x == limits[1] or next.x == limits[2]) then
			caminoRecto = 2
	)
	--Se elige giro
	else (
		--Si JUSTO va a girar antes de acabar el camino, se extiende una casilla mas
		if(posibleNext.x > (tamX*4/5) and (posibleNext.x == limits[1]-1 or posibleNext.x == limits[2]+1 or posibleNext.y == limits[3]-1 or posibleNext.y == limits[4]+1)) then(
			print "casi giro al final del mapa :D"
			next = posibleNext
			caminoRecto = 2
		)
		--si no, seguimos normalmente
		else (
			local moveY = 0
			local moveX = 0
			local maxCamino = 4

			--por si acaso se comprueba la zona peligrosa
			if last.x < (tamX/5*4) and (last.y > (tamY-4)) then (
				girarAbajo = true
				if opcion == 0 then zonaPeligrosa = true
				
				print "se activa zona peligrosa"
			)
			--la otra zona peligrosa
			else if last.x < (tamX/5*4) and (last.y < 4) then (
				girarArriba = true
				
				if opcion == 3 then zonaPeligrosa = true
			)
			--si esta en zona peligrosa para salirse, nos alejamos de ella
			if (zonaPeligrosa) then(
				moveX = 1
				moveY = 0
				
				print "se entra en zona peligrosa, moverse a la derecha"
				zonaPeligrosa = false
			)
			else if girarArriba then(
				moveX = 0
				moveY = 1
				
				print "Giro hacia arriba forzado"
				girarArriba = false
			)
			else if girarAbajo then(
				moveX = 0
				moveY = -1
				
				print "Giro hacia abajo forzado"
				girarAbajo = false
			)
			else (
				print("Giro normalmente. CaminoRecto: "+(caminoRecto as String) )
				moveX = 1
				
				--Mientras se quiera bajar o subir, se comprueba que no venga ya de bajar(3) o subir(0)
				moveY = random -1 1
				if moveY==-1 then (
					if opcion == 0 then moveY= random 0 1
				)
				else if moveY==1 then (
					if opcion == 3 then moveY = random -1 0
				)
				if(moveY == -1 or moveY == 1) then(
					moveX = 0
					
					local dist = checkDirection actual [next.x, next.y+moveY]
					if dist < 4 then maxCamino = dist-1
				)
				else moveX = 1
			)
			
			next = [next.x + moveX, next.y+moveY]
			
			caminoRecto = random 2 maxCamino
		)
	)
)

fn crearCamino uselessParam = (
	local terminado = false
	caminoRecto = random 1 5
	local piezasdesconocidas = 0
	
	--se declaran las posiciones que se iran actualizando
	local lastpos = [0, 0]
	local actualpos = [0, 0]
	local nextpos = [0, 0]
	
	--se encuentra la posicion inicial del rio y se obtienen los limites
	local tipo = startCamino &actualpos &lastpos &nextpos
	local limites = getLimites tipo

	print("Inicial: "+(actualpos as String) + " Siguiente: "+(nextpos as String) )

	print "\n EMPIEZA EL CAMINO"
	do(		
		--se recorre la matriz de nombres y se selecciona el actual
		local nombre = sueloArray[actualpos.x][actualpos.y]
		execute ("select $'"+ nombre + "'")

		--se comprueba que la casilla seleccionada sea una pieza de suelo
		if (findString $.name "suelo" > 0) then(
			--Se almacena la posicion del objeto de suelo para poder reemplazarlo por el camino y borrarlo
			local pos2move = $.pos
			delete $
			
			--Se importa la pieza correspondiente dependiendo de la casilla anterior y posterior
			getPiezacamino lastpos actualpos nextpos
			
			$.pos = pos2move
			local baseName = $.name
			$.name = uniquename (baseName as string)
			sueloArray[actualpos.x][actualpos.y] = $.name
			
			--Se actualizan las posiciones y se avanza a la siguiente casilla
			updateCamino limites &lastpos &actualpos &nextpos
			print("Actual: "+(actualpos as String) + " Siguiente: "+(nextpos as String) )
			
			--Comprobacion para terminar el nivel
			if(lastpos.x > (tamX/5*4) and (lastpos.y == tamY or lastpos.y == 1 or lastpos.x == tamX)) then (
				terminado = true
				local tip = comparaPos lastpos actualpos
				nextpos = posPorOpcion tip nextpos
			)
		)
		else(
			print "PIEZA INESPERADA: "+$.name			
			
			--evitamos bucle infinito
			piezasdesconocidas += 1
			if piezasdesconocidas > 5 then
				terminado = true
		)
		clearSelection()
	)while (not terminado)
)

fn spawnTorre idbase idcuerpo idtecho = (
	local baseName
	local base
	local cuerpo
	local cuerpo2
	local techo
	--Se importa el modelo de la base y se le cambia el nombre
	importModel basesT[idbase]
	baseName = $.name
	$.name = uniquename (baseName as string)
	move $ [0,0,4]
	base = $
	clearselection()
	
	--Se importa el modelo del cuerpo y se le cambia el nombre y la posicion
	importModel cuerposT[idcuerpo]
	baseName = $.name
	$.name = uniquename (baseName as string)
	move $ [0,0,8]
	rotate $ (angleaxis -90 [0,0,1])
	cuerpo = $
	clearselection()

	--Se importa el modelo del techo y se le cambia el nombre y la posicion
	importModel techosT[idtecho]
	baseName = $.name
	$.name = uniquename (baseName as string)
	if idtecho == 2 then move $ [0,0,15.13]
	else if idtecho == 7 or idtecho == 8 or idtecho == 9 then move $ [0,0,12.4]
	else move $ [0,0,14.8359]
	rotate $ (angleaxis -90 [0,0,1])
	techo = $
	clearselection()
	
	select cuerpo
	selectmore techo
	$.parent = base
	select base
	
	local nombreUnic = uniquename ("Torre")
)

fn generarTorres uselessParam = (
	local torresRestantes = nTorres
	if not usingTowerAmount then torresRestantes = maxTorres*porTorres/100
	local posR = -1
	
	local count = 0
	do(
		local inserted = false
		local xory = random 0 1
		
		if (xory == 0) then(
			posR = random 1 tamY
			
			local x=1
			while (x<tamX-1 and not inserted) do(
				if x == tamX-1 then inserted =true
				else if (findstring sueloArray[x+1][posR] "linea" != undefined and findstring sueloArray[x][posR] "suelo" != undefined) then(
					
					--se selecciona el objeto
					local nombre = sueloArray[x][posR]
					execute ("select $'"+ nombre + "'")
					
					local pos = $.pos
					
					local rp1 = random 1 7
					local rp2 = random 1 6
					local rp3 = random 1 9
					spawnTorre rp1 rp2 rp3
					
					$.pos= pos
					move $ [0,0,4]
					sueloArray[x][posR] = uniqueName("Torre")					
					
					torresRestantes -= 1
					inserted = true
				)
				x+=1
			)
		)
		else(
			posR = random 1 (tamX)
			local y=1 
			while (y<tamY-1 and not inserted) do(
				if y == tamY-1 then inserted =true
				else if (findstring sueloArray[posR][y+1] "linea" != undefined and findstring sueloArray[posR][y] "suelo" != undefined ) then(
					--se selecciona el objeto
					local nombre = sueloArray[posR][y]
					execute ("select $'"+ nombre + "'")
					
					local pos = $.pos
					
					local rp1 = random 1 7
					local rp2 = random 1 6
					local rp3 = random 1 9
					spawnTorre rp1 rp2 rp3
					
					$.pos= pos
					move $ [0,0,4]
					sueloArray[posR][y] = uniqueName("Torre")
					
					torresRestantes-=1
					inserted = true
				)
				y+=1
			)
		)
		count+=1
	)while (torresRestantes > 0 and count < 20)
)

fn generarDecoracion uselessParam = (
	if(randomPiezasD) then (
		
	)
	else (
		
	)
)

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- ROLLOUTS //////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
rollout generadorTD "Tower Defense Generator" width:210 height:710(
	subRollout rollDentro "Dentro" pos:[5,10] width:200 height:700
)

-- GENERAL

rollout general "General" width:296 height:104(
	group "Global buttons"(	
		button 'btnRandom' "RANDOMIZE" width:80 height:20 enabled:true align:#left
		button 'btnRestart' "RESTART" width:80 height:20 enabled:true  align:#right offset:[0, -25]
	)
	group "Level Position"(
		spinner spinPosicionCX "X: " width:64 height:16 range:[-200,200,centroX] align:#center type:#float scale:0.5
		spinner spinPosicionCY "Y: " width:64 height:16 range:[-200,200,centroY] align:#center type:#float scale:0.5
		spinner spinPosicionCZ "Z: " width:64 height:16 range:[-50, 50,centroZ] align:#center type:#float scale:0.5
		button btnCenter "CENTER" width:80 height:20 enabled:true  align:#left
		button btnOrigen "ORIGIN" width:80 height:20 enabled:true  align:#right offset:[0, -25]
		
		on spinPosicionCX changed param do (centroX = spinPosicionCX.value)
		on spinPosicionCY changed param do (centroY = spinPosicionCY.value)
		on spinPosicionCZ changed param do (centroZ = spinPosicionCZ.value)
		
		--BOTON CENTER
		on btnCenter pressed do (
			spinPosicionCX.value = tamX*tamanoBloque/2.0 * -1.0
			spinPosicionCY.value = tamY*tamanoBloque/2.0 * -1.0
			spinPosicionCZ.value = 0
			
			centroX = spinPosicionCX.value
			centroY = spinPosicionCY.value
			centroZ = 0
		)
		--BOTON ORIGIN
		on btnOrigen pressed do (
			spinPosicionCX.value = 0
			spinPosicionCY.value = 0
			spinPosicionCZ.value = 0
			
			centroX = 0
			centroY = 0
			centroZ = 0
		)
	)
	
	group "Grid Size"(
		spinner spinTamX "Size X" range:[10, 30, tamX] type:#integer align:#center
		spinner spinTamY "Size Y" range:[10, tamX, tamY] type:#integer align:#center
		
		on spinTamX changed param do(
			tamX = param
			if tamY>param then tamY = param
			spinTamY.range= [10, param, tamY]
			
			updateNTowers tamX tamY
		)
		on spinTamY changed param do(
			tamY = param
			
			updateNTowers tamX tamY
		)
	)
	
	group "Individual Block Size"(
		dropdownList dpdwTmnoBloque "Block size" width:100 height:21 items:#("5/3 (original)", "5", "10 (Grid sized)") selection: 3 align:#center

		on dpdwTmnoBloque selected i do
		(
			if i == 1 then(
				tamanoBloque = 5.0/3.0
				altura = 1.0/3.0
			)
			else if i == 2 then(
				tamanoBloque = 5.0
				altura = 1
			)
			else if i == 3 then(
				tamanoBloque = 10.0
				altura = 2
			)
		)
	)
	
	-- BOTON RANDOM
	on btnRandom pressed do (
		spinTamX.value = random 10 30
		tamX = spinTamX.value
		spinTamY.value = random 10 tamX
		tamY =  spinTamY.value
		spinTamY.range= [10, tamX, tamY]
		
		--actualizar torres maximas
		updateNTowers tamX tamY
		
		customDecoracion.chkRandomDecoration.state = true
		randomPiezasD =true
		customDecoracion.chkTreeN.enabled = false
		customDecoracion.chkTreeT.enabled = false
		customDecoracion.chkTreeP.enabled = false
		customDecoracion.chkRockN.enabled = false
		customDecoracion.chkRockD.enabled = false
		customDecoracion.spinPDecoration.enabled = false
	)
	-- BOTON RESTART
	on btnRestart pressed do (
		spinTamX.value = 10
		updateTamX 10
		spinTamY.value = 10
		updateTamY 10
		
		customDecoracion.chkRandomDecoration.state = false
		randomPiezasD = false
		customDecoracion.chkTreeN.enabled = true
		customDecoracion.chkTreeT.enabled = true
		customDecoracion.chkTreeP.enabled = true
		customDecoracion.chkRockN.enabled = true
		customDecoracion.chkRockD.enabled = true
		customDecoracion.spinPDecoration.enabled = true
	)
)

-- TORRES
rollout customTorres "Towers" width:296 height:104(
	group "Ammount"(
		radiobuttons num_torres columns:1 align:#left
		labels:#("Number: ", "Number(%): ")
		offsets:#([0,0], [0,5]) 
		
		spinner spinNTorres width:50 height:16 range:[0, maxTorres, nTorres] type:#integer align:#right offset:[0, -40]
		spinner spinPTorres width:50 height:16 range:[0,       100, 50] type:#integer align:#right enabled:false
		-- TODO: Poner que el 100% de las torres sea el 10% de todo el nivel
		on num_torres changed state do (
			if num_torres.state == 1 then (
				usingTowerAmount = true
				spinNTorres.enabled = true 
				spinPTorres.enabled = false
			)
			else (
				usingTowerAmount = false
				spinNTorres.enabled = false 
				spinPTorres.enabled = true
			)
		)
		on spinNTorres changed state do (
			nTorres = spinNTorres.value
			spinNTorres.range =  [0, maxTorres, spinNTorres.value]
		)
		on spinPTorres changed state do (
			porTorres = spinPTorres.value
		)
	)
	group "Structure"(
		checkbox chkRandomTower "Randomize Tower Parts" 
		on chkRandomTower changed state do(
			randomPiezasT = state
		)
	)
)

-- DECORACION
rollout customDecoracion "Decoration" width:296 height:104(
	checkBox chkRandomDecoration "Randomize Decoration" 

	group "Types"(
		checkBox chkTreeN "Normal Trees"  checked:true
		checkBox chkTreeT "Triple Trees" checked:true
		checkBox chkTreeP "Pink Trees" checked:true
		checkBox chkRockN "Normal Rocks" checked:true
		checkBox chkRockD "Double Rocks" checked:true

		on chkTreeN changed state do(	arboles= state)
		on chkTreeT changed state do(	arbolesTriples = state	)
		on chkTreeP changed state do(	arbolesRosas = state)
		on chkRockN changed state do(	piedras = state	)
		on chkRockD changed state do(	piedrasDobles = state	)
		
	)
	group "Amount"(
		spinner spinPDecoration "Number (%)" width:100 height:16 range:[0, 100, 20] type:#integer align:#left 
		on spinPDecoration changed state do (
			porDecoracion = spinPDecoration.value
		)
	)
	
	on chkRandomDecoration changed state do(
		if chkRandomDecoration.state == true then (
			randomPiezasD =true
			chkTreeN.enabled = false
			chkTreeT.enabled = false
			chkTreeP.enabled = false
			chkRockN.enabled = false
			chkRockD.enabled = false
			spinPDecoration.enabled = false
		)
		else (
			randomPiezasD =false
			chkTreeN.enabled = true
			chkTreeT.enabled = true
			chkTreeP.enabled = true
			chkRockN.enabled = true
			chkRockD.enabled = true
			spinPDecoration.enabled = true
		)
	)
)

-- ILUMINACION
rollout customIlumination "Ilumination" width:296 height:104(
	checkBox chkRandomIlumination "Randomize Ilumination" 

	group "General"(
		Slider sldBright "Scene Brightness" width:180 range:[0,100,0] type:#integer ticks:10 orient:#horizontal
		checkBox chkShadows "Scene Shadows" checked:true
	)
	
	on chkRandomIlumination changed state do(
		randomIluminacion = state
		sldBright.enabled = not state
	)
	on chkShadows changed state do(
		sceneShadows =true
	)
)

rollout generar "Generate Level" width:296 height:104(
	button 'btnGenerar' "GENERATE" width:120 height:20 align:#center
	on btnGenerar pressed do (
		if(queryBox  "Escene Objects will be DELETED. Continue?" == true) then (
			--Borrar objetos
			delete objects
			free objects
			--Actualizar valores
			
			--Generar Mapa
			crearSuelo 0
			--crearRio 0
			crearCamino 0
			generarTorres 0
			generarDecoracion 0
			
			--Crear Camara
			local camx = centroX - 50
			local camy = centroy - 50
			local camz = 50
			local targetx = (centroX + tamX * tamanoBloque/2.0)
			local targety = (centroY + tamY * tamanoBloque/2.0)
			Targetcamera fov:45 nearclip:1 farclip:1000 nearrange:0 farrange:1000 mpassEnabled:off mpassRenderPerPass:off pos:[camx,camy,camz] isSelected:on target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [targetx,targety,1]))
		)
	)
)

-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- GENERAR MENU /////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --

createdialog generadorTD
AddSubRollout generadorTD.rollDentro general
AddSubRollout generadorTD.rollDentro customTorres
AddSubRollout generadorTD.rollDentro customDecoracion
--AddSubRollout generadorTD.rollDentro customIlumination
AddSubRollout generadorTD.rollDentro generar

