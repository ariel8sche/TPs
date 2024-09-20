-- Guarachi Rodrigo
-- Maldonado Axel
-- Schenone Ariel

-- Segundo trabajo práctico
-- Números complejos

-- Renombre de tipo para complejos

type Complejo = (Float,Float)

-- EJERCICIO 1

-- 1.1 PARTE REAL DEL NÚMERO COMPLEJO

re :: Complejo -> Float
re (a,b) = a

-- 1.2 PARTE IMAGINARIA DEL NÚMERO COMPLEJO

im :: Complejo -> Float
im (a,b) = b

-- 1.3 SUMA DE DOS NÚMEROS COMPLEJOS

suma :: Complejo -> Complejo -> Complejo
suma (a,b) (c,d) = (a + c, b + d)

-- 1.4 PRODUCTO DE DOS NÚMEROS COMPLEJOS

producto :: Complejo -> Complejo -> Complejo
producto (a,b) (c,d) = ((a*c)-(b*d),(a*d)+(b*c))

-- 1.5 CONJUGADO DE UN NÚMERO COMPLEJO

conjugado :: Complejo -> Complejo
conjugado (a,b) = (a,-b)

-- 1.6. INVERSO DE UN NÚMERO COMPLEJO

-- Se implementa la función "división" para poder dividir a un numero complejo con un
-- número real, tendrá utilidad en ejercicios siguientes.

division :: Complejo -> Float -> Complejo
division (a,b) x = (a/x,b/x)

inverso :: Complejo -> Complejo
inverso (a,b) = division (conjugado (a,b)) (a*a+b*b)

-- 1.7. COCIENTE DE UN NÚMERO COMPLEJO

cociente :: Complejo -> Complejo -> Complejo
cociente z w = producto z (inverso w)

-- 1.8. POTENCIA DE UN NÚMERO COMPLEJO

potencia :: Complejo -> Integer -> Complejo
potencia z 1 = z
potencia z k = producto z (potencia z (k-1))

-- 1.9. RAÍCES COMPLEJAS DE LA ECUACIÓN CUADRÁTICA: A*X^2+B*X+C=0, SIENDO A,B,C NÚMEROS REALES

-- En la primera guarda se prueba si las raíces son números reales,
-- de lo contrario se mueve el cálculo de la raiz cuadratica a la parte imaginaria.

raicesCuadratica :: Float -> Float -> Float -> (Complejo, Complejo)
raicesCuadratica a b c | b^2 > 4*a*c = ((cociente (-b-sqrt(b^2-4*a*c),0) (2*a,0)), (cociente (-b+sqrt(b^2-4*a*c),0) (2*a,0)))
                       | otherwise = ((cociente (-b,-sqrt(abs(b^2-4*a*c))) (2*a,0)), (cociente (-b,sqrt(abs(b^2-4*a*c))) (2*a,0)))

-- EJERCICIO 2

-- 2.1 MÓDULO DE UN NÚMERO COMPLEJO

modulo :: Complejo -> Float
modulo (a,b) = sqrt(a^2 + b^2)

-- 2.2. DISTANCIA ENTRE DOS NÚMEROS COMPLEJOS (EN EL PLANO COMPLEJO)

-- Implemento la función "resta" que también será de utilidad en el ejercicio 2.6 

resta :: Complejo -> Complejo -> Complejo
resta z w = ((re z)-(re w),(im z)-(im w))

distancia :: Complejo -> Complejo -> Float
distancia z w = modulo (resta z w)

-- 2.3 ARGUMENTO DE UN NÚMERO COMPLEJO

-- Para que el argumento este en el intervalo [0,2*pi], se implemento la función "arg" que
-- resuelve el problema de los cuadrantes y "argumento" que resuelve el problema de
-- los argumentos negativos. 

arg :: Complejo -> Float
arg (a,b) | a >= 0 = atan(b/a)
          | otherwise = atan(b/a) + pi

argumento :: Complejo -> Float
argumento (a,b) | arg(a,b) < 0 = 2*pi + arg(a,b)
                | otherwise = arg(a,b)

-- 2.4 CONVERSIÓN DE UN NÚMERO COMPLEJO DE EXPRESIÓN POLAR A CARTESIANA

pasarACartesianas :: Float -> Float -> Complejo
pasarACartesianas r t = (r*cos(t), r*sin(t))

-- 2.5 SOLUCIONES DE: W^2=Z, EL CUAL "Z" ES EL NÚMERO COMPLEJO DADO

-- Se implementan las funciones "raizCuadradaPrimera" y "raizCuadradaSegunda" para que el código no sea muy
-- extenso horizontalmente. 

raizCuadrada :: Complejo -> (Complejo,Complejo)
raizCuadrada (a,b) = (raizCuadradaPrimera (a,b) , raizCuadradaSegunda (a,b))

raizCuadradaPrimera :: Complejo -> Complejo
raizCuadradaPrimera (0,0) = (0,0)
raizCuadradaPrimera (a,b) = pasarACartesianas (sqrt (modulo (a,b))) ((argumento (a,b))/2)

raizCuadradaSegunda :: Complejo -> Complejo
raizCuadradaSegunda (0,0) = (0,0)
raizCuadradaSegunda (a,b) = pasarACartesianas (sqrt (modulo (a,b))) ((2*pi + (argumento (a,b)))/2)

-- 2.6 RAÍCES COMPLEJAS DE LA ECUACIÓN CUADRÁTICA: A*X^2+B*X+C=0, SIENDO A,B,C NÚMEROS COMPLEJOS

-- Así como en el ejercicio anterior, se implementan las funciones "discriminante", "raizCuadraticaComplejaSegunda" y
-- "raizCuadraticaComplejaPrimera" para evitar que el código se extienda demasiado horizontalmente.

discriminante :: Complejo -> Complejo -> Complejo -> Complejo
discriminante a b c = raizCuadradaSegunda (resta (potencia b 2) (division (producto a c) 0.25))

raizCuadraticaComplejaSegunda :: Complejo -> Complejo -> Complejo -> Complejo
raizCuadraticaComplejaSegunda a b c = cociente (resta (division b (-1)) (discriminante a b c)) (division a 0.5)

raizCuadraticaComplejaPrimera :: Complejo -> Complejo -> Complejo -> Complejo
raizCuadraticaComplejaPrimera a b c = cociente (suma (division b (-1)) (discriminante a b c)) (division a 0.5)

raicesCuadraticaCompleja :: Complejo -> Complejo -> Complejo -> (Complejo,Complejo)
raicesCuadraticaCompleja a b c = (raizCuadraticaComplejaPrimera a b c,raizCuadraticaComplejaSegunda a b c)

-- EJERCICIO 3

-- 3.1. LISTA CON LAS RAÍCES N-ÉSIMAS DE LA UNIDAD

-- Implemento la función "cis1" para hallar los elementos k-ésimos de las raíces n-ésimas de la unidad

cis1 :: Integer -> Integer -> (Float,Float)
cis1 n k = (cos (2*pi*(fromIntegral k)/(fromIntegral n)),sin (2*pi*(fromIntegral k)/(fromIntegral n)))

--Implemento la función auxiliar "raicesNEsimasDesde" y finalmente "raicesNEsimas"

raicesNEsimasDesde :: Integer -> Integer -> [Complejo]
raicesNEsimasDesde n k | n == k = []
                       | otherwise = (cis1 n k):(raicesNEsimasDesde n (k+1))

raicesNEsimas :: Integer -> [Complejo]
raicesNEsimas n = raicesNEsimasDesde n 0 

-- 3.2. SON RAICES N-ÉSIMAS DE LA UNIDAD

-- Verifica que dada una lista de números complejos, todos ellos sean raíces n-ésimas de la unidad.
-- NOTA: La función no responde con e = 10^(-4), por que no responde con exponentes negativos, pero
--       si responde con su equivalente e = 1e-4

sonRaicesNEsimas :: Integer -> [Complejo] -> Float -> Bool
sonRaicesNEsimas n [] e = True
sonRaicesNEsimas n (x:xs) e = ((distancia (potencia x n) (1,0)) < e) && sonRaicesNEsimas n xs e