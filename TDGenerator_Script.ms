-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- INICIALIZACION ///////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
delete objects
free objects
viewport.setType #view_persp_user
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
tamZ = 6

tamanoBloque = 10.0
altura= 2.0

sueloArray = #(#(#()))

--Torres
maxTorres = tamX*tamY/10
usingTowerAmount = true
nTorres = maxTorres/2 
porTorres = 50
randomPiezasT = false
	
--Decoracion
randomPiezasD = false
porDecoracion = 20

--Iluminacion
randomIluminacion = false
sceneShadows = true

chkRandomDecoration
	
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- MODELOS //////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
suelo = sysInfo.currentdir + "\modelos\piezaSuelo.3ds"
linea = sysInfo.currentdir + "\modelos\piezaLinea.3ds"
giroLinea = sysInfo.currentdir + "\modelos\giroLinea.3ds"
rio = sysInfo.currentdir + "\modelos\piezaRio.3ds"
giroRio= sysInfo.currentdir + "\modelos\giroRio.3ds"
puente = sysInfo.currentdir + "\modelos\puente.3ds"

arbolRosa = sysInfo.currentdir + "\modelos\arbolRosa.3ds"
arbol = sysInfo.currentdir + "\modelos\arbol.3ds"
arbolTriple = sysInfo.currentdir + "\modelos\arbolTriple.3ds"
piedra = sysInfo.currentdir + "\modelos\piedra.3ds"
piedraDoble = sysInfo.currentdir + "\modelos\piedraDoble.3ds"

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

fn updateTamX ptamx = (
	tamX = ptamx
	maxTorres = tamX*tamY/10
	if nTorres > maxTorres then (
		nTorres = maxTorres
	)
)

fn updateTamY ptamy = (
	tamY = ptamy
	maxTorres = tamX*tamY/10
	if nTorres > maxTorres then (
		nTorres = maxTorres
	)
)

fn crearSuelo ptamX ptamY = (
	for y= 1 to ptamY do(
		for x=1 to ptamX do(
			importModel suelo2
			baseName = $.name
			$.name = uniquename (baseName as string)
			--suelo[1][y][x] = "Suelo"
			
			move $ [(x-1) * tamanoBloque, (y-1) * tamanoBloque, 0]
			clearSelection()
		)
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
		spinner spinPosicionCX "X: " width:64 height:16 range:[-100,100,centroX] align:#center type:#integer
		spinner spinPosicionCY "Y: " width:64 height:16 range:[-100,100,centroY] align:#center type:#integer
		spinner spinPosicionCZ "Z: " width:64 height:16 range:[-100,100,centroZ] align:#center type:#integer
		button btnCenter "CENTER" width:80 height:20 enabled:true  align:#center
		
		on spinPosicionCX changed param do (centroX = spinPosicionCX.value)
		on spinPosicionCY changed param do (centroY = spinPosicionCY.value)
		on spinPosicionCZ changed param do (centroZ = spinPosicionCZ.value)
		
		on btnCenter pressed do (
			spinPosicionCX.value	= tamX/2.0 * -1
			spinPosicionCY.value	= tamY/2.0 * -1
			spinPosicionCZ.value	= 0
			
			centroX = spinPosicionCX.value
			centroY = spinPosicionCY.value
			centroZ = 0
		)
	)
	
	group "Grid Size"(	
		spinner spinTamX "Size X" range:[10, 40, tamX] type:#integer align:#center
		spinner spinTamY "Size Y" range:[10, 40, tamY] type:#integer align:#center
		
		on spinTamX changed param do(
			updateTamX spinTamX.value		
		)
		on spinTamY changed param do( 
			updateTamY spinTamY.value
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
			-- print tamanoBloque
		)
	)
	
	on btnRandom pressed do (
			spinTamX.value = random 10 40
			updateTamX spinTamX.value
			spinTamY.value = random 10 40
			updateTamY spinTamY.value
		
			-- chkRandomDecoration
	)
		on btnRestart pressed do (
			spinTamX.value = 10
			updateTamX 10
			spinTamY.value = 10
			updateTamY 10
			
			
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
		checkBox chkTreeN "Normal Trees" 
		checkBox chkTreeT "Triple Trees"
		checkBox chkTreeP "Pink Trees"
		checkBox chkRockN "Normal Rocks"
		checkBox chkRockD "Double Rocks"
		
		on chkTreeN changed state do(
			print state
		)
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
		delete objects
		free objects
		
		/*sueloArray = #(#(#()))
		for z=1 to tamZ do (
			append sueloArray #()
			for y=1 to tamY do (
				append sueloArray[z] #()
				for x=1 to tamX do (
					append sueloArray[z][y] #()
				)
			)
		)*/
		crearSuelo tamX tamY
		Targetcamera fov:45 nearclip:1 farclip:1000 nearrange:0 farrange:1000 mpassEnabled:off mpassRenderPerPass:off pos:[-50,-50,50] isSelected:on target:(Targetobject transform:(matrix3 [1,0,0] [0,1,0] [0,0,1] [50 ,50,1]))
	)
)


-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- GENERAR MENÚ /////////////////////////////////////////////////////////////////////////////////////////////////////// --
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// --

createdialog generadorTD
AddSubRollout generadorTD.rollDentro general
AddSubRollout generadorTD.rollDentro customTorres
AddSubRollout generadorTD.rollDentro customDecoracion
AddSubRollout generadorTD.rollDentro customIlumination
AddSubRollout generadorTD.rollDentro generar

