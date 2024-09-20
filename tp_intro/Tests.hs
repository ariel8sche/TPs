import Test.HUnit
import Solucion

-- Definimos funciones constantes para hacer testing:
u1 = (1,"User1")
u2 = (2,"User2")
u3 = (3,"User3")
u4 = (4,"User4")
u5 = (5,"User5")
u6 = (6,"User6")
u7 = (7,"User7")
u8 = (8,"User8")
u9 = (9,"User9")
u10 = (10,"User10")
u11 = (11,"User11")
u12 = (12,"User12")

testNoUsers = []
testAllUsers = [u1,u2,u3,u4,u5,u6,u7,u8,u9,u11,u12]
testUsers = [u1,u2,u3,u4]

testRelEmpty = []
testRelDirecta = [(u1,u4)]
testRelCadena = [(u1,u2), (u3,u2), (u3,u4)]
testNoRel = [(u1,u2), (u4,u3)]
testSoloU1 = [(u1,u2)]
testSoloU4 = [(u4,u2)]

testRobertoCarlos = [(u1, u) | u <- [u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12]]

testPubliEmpty = []
testPubli = [(u2, "Buenas", [u1,u2]), (u4, "Cómo están?", []), (u2, "Malas", [u3])]
-- Fin de la definición

main = runTestTT todosLosTest

todosLosTest = test [
    nombresDeUsuariosTestSuite,
    amigosDeTestSuite,
    cantidadDeAmigosTestSuite,
    usuarioConMasAmigosTestSuite,
    estaRobertoCarlosTestSuite,
    publicacionesDeTestSuite,
    publicacionesQueLeGustanATestSuite,
    lesGustanLasMismasPublicacionesTestSuite,
    tieneUnSeguidorFielTestSuite,
    existeSecuenciaDeAmigosTestSuite
    ]

nombresDeUsuariosTestSuite = test [
    "Caso 1: no hay usuarios" ~: nombresDeUsuarios ([],[],[]) ~?= [],
    "Caso 2: hay usuarios" ~: nombresDeUsuarios (testUsers,[],[]) ~?= ["User1", "User2", "User3", "User4"]
    ]

amigosDeTestSuite = test [
    "Caso 1: u1 no tiene amigos " ~: amigosDe (testUsers,[(u2,u3)],[]) u1 ~?= [],
    "Caso 2: u1 tiene amigos" ~: amigosDe (testUsers,[(u1,u2), (u3,u1)],[]) u1 ~?= [u2, u3]
    ]

cantidadDeAmigosTestSuite = test [
    "Caso 1: u1 no tiene amigos " ~: cantidadDeAmigos (testUsers,[(u2,u3)],[]) u1 ~?= 0,
    "Caso 2: u1 tiene amigos" ~: cantidadDeAmigos (testUsers,[(u1,u2), (u3,u1)],[]) u1 ~?= 2
    ]

usuarioConMasAmigosTestSuite = test [
    "Caso 1: nadie tiene amigos" ~: usuarioConMasAmigos (testUsers,[],[]) ~?= u1,
    "Caso 1: dos o más usuarios tienen la misma cantidad de amigos" ~: usuarioConMasAmigos (testUsers,[(u4,u2), (u4,u3), (u2,u3)],[]) ~?= u2,
    "Caso 2: sólo un usuario tiene más amigos" ~: usuarioConMasAmigos (testUsers,[(u1,u2), (u1,u3)],[]) ~?= u1
    ]

estaRobertoCarlosTestSuite = test [
    "Caso 1: u1 no tiene más de 10 amigos (u1 es roberto cartlos)" ~: estaRobertoCarlos (testUsers,[(u1,u3)],[]) ~?= False,
    "Caso 2: u1 tiene más de 10 amigos (u1 es roberto carlos)" ~: estaRobertoCarlos (testUsers,testRobertoCarlos,[]) ~?= True
    ]

publicacionesDeTestSuite = test [
    "Caso 1: u2 no tiene publicaciones" ~: publicacionesDe (testUsers,[],[]) u2 ~?= [],
    "Caso 2: u2 tiene publicaciones" ~: publicacionesDe (testUsers,[],testPubli) u2 ~?= [(u2, "Buenas", [u1,u2]), (u2, "Malas", [u3])]
    ]

publicacionesQueLeGustanATestSuite = test [
    "Caso 1: a un usuario (u4) no le gusta nada (es un mala onda)" ~: publicacionesQueLeGustanA (testUsers,[],testPubli) u4 ~?= [],
    "Caso 2: a un usuario (u1) le gusta una o más publicaciones" ~: publicacionesQueLeGustanA (testUsers,[],testPubli) u1 ~?= [(u2, "Buenas", [u1,u2])]
    ]

lesGustanLasMismasPublicacionesTestSuite = test [
    "Caso 1: no le gustan las mismas publicaciones a u1 y a u2" ~: lesGustanLasMismasPublicaciones (testUsers,[],[(u2, "Buenas", [u1]), (u4, "Cómo están?", [u3]), (u2, "Malas", [u2,u1])]) u1 u2 ~?= False,
    "Caso 2: le gustan las mismas publicaciones a u1 y u2" ~: lesGustanLasMismasPublicaciones (testUsers,[],[(u2, "Buenas", [u1,u2]), (u4, "Cómo están?", [u3]), (u2, "Malas", [u2,u1])]) u1 u2 ~?= True
    ]

tieneUnSeguidorFielTestSuite = test [
    "Caso 1: u2 no tiene publicaciones" ~: tieneUnSeguidorFiel (testUsers,[],[(u4, "Cómo están?", [u3])]) u2 ~?= False, -- Este caso lo hicimos aparte por la especificación (res <=> ...)
    "Caso 2: u2 el único seguidor fiel es si mismo" ~: tieneUnSeguidorFiel (testUsers,[],[(u2, "Buenas", [u2]), (u4, "Cómo están?", [u3]), (u2, "Malas", [u2])]) u2 ~?= False,
    "Caso 3: u2 no tiene ningún seguidor fiel" ~: tieneUnSeguidorFiel (testUsers,[],[(u2, "Buenas", []), (u4, "Cómo están?", [u3]), (u2, "Malas", [])]) u2 ~?= False,
    "Caso 4: u2 tiene algún seguidor fiel distinto a si mismo" ~: tieneUnSeguidorFiel (testUsers,[],[(u2, "Buenas", [u1,u2]), (u4, "Cómo están?", [u3]), (u2, "Malas", [u2,u1])]) u2 ~?= True
    ]

-- Todas las secuencias de amigos se busca entre u1 y u4.
existeSecuenciaDeAmigosTestSuite = test [
    "Caso 1: hay una secuencia directa entre u1 y u4" ~: existeSecuenciaDeAmigos (testUsers,testRelDirecta,[]) u1 u4 ~?= True,
    "Caso 2: hay una secuencia (no directa, cadena) entre u1 y u4" ~: existeSecuenciaDeAmigos (testUsers,testRelCadena,[]) u1 u4 ~?= True,
    "Caso 3: no existe una secuencia de amigos entre u1 y u4." ~: existeSecuenciaDeAmigos (testUsers,testNoRel,[]) u1 u4 ~?= False
--    "Caso 4: no hay relaciones" ~: existeSecuenciaDeAmigos (testUsers,testRelEmpty,[]) u1 u4 ~?= False,
--    "Caso 5: u4 no tiene amigos" ~: existeSecuenciaDeAmigos (testUsers,testSoloU1,[]) u1 u4 ~?= False,
--    "Caso 6: u1 no tiene amigos" ~: existeSecuenciaDeAmigos (testUsers,testSoloU4,[]) u1 u4 ~?= False
    ]
