-- Guarachi Rodrigo
-- Maldonado Axel
-- Schenone Ariel

-- Primer trabajo práctico
-- Números pseudoprimos y de Carmichael

-- EJERCICIO 1 

-- Se implementa la función "mcd" (Máximo Común Divisor)

mcd :: Integer -> Integer -> Integer
mcd a b | abs b > abs a = mcd b a
mcd a 0 = abs a
mcd a b = mcd b (mod a b)

-- Ahora se implementa la función "sonCoprimos"
-- Dos numeros enteros son coprimos si su Máximo Común Divisor es 1: (a:b)=1 

sonCoprimos :: Integer -> Integer -> Bool
sonCoprimos a b | mcd a b == 1 = True
                | otherwise = False

--EJERCICIO 2

-- Se implementa la función "menorDivisor" con su auxiliar "menorDivisorDesde"
-- y la función "esPrimo" (Ej. 4 y 5 de la Clase 5)

menorDivisorDesde :: Integer -> Integer -> Integer
menorDivisorDesde n i | mod n i == 0 = i
                      | otherwise = menorDivisorDesde n (i+1)

menorDivisor :: Integer -> Integer
menorDivisor n = menorDivisorDesde n 2

esPrimo :: Integer -> Bool
esPrimo n | menorDivisor n == n = True
          | otherwise = False

-- Se implementa la función "esCompuesto"
-- NOTA: Es la negación de la función "esPrimo" pero se añade la restricción
-- que no sea igual a 1 porque no es primo pero tampoco es compuesto.

esCompuesto :: Integer -> Bool
esCompuesto n | n == 1 = False
              | otherwise = not(esPrimo n)
 
-- Se implementa la función "esAPseudoprimo" (a-Pseudoprimo)
-- NOTA: Esta función es la más importante ya que es la base para armar este y
--      los demás ejercicios. Ya que "n" debe ser un número natural compuesto, se
--      aplica la restricción: "n < 4 = False", ya que 4 es el menor de los
--      números compuestos (naturales).

esAPseudoprimo :: Integer -> Integer -> Bool
esAPseudoprimo a n | n < 4 = False
                   | ((a^(n-1) `mod` n) == 1) && (esCompuesto n) == True = True
                   | otherwise = False

-- Finalmente se implementa la función es2Pseudoprimo (2-Pseudoprimo)

es2Pseudoprimo :: Integer -> Bool
es2Pseudoprimo n = esAPseudoprimo 2 n 

-- EJERCICIO 3

-- Se implementa la función "cantidad3Pseudoprimos"
-- NOTA: Se toma como referencia al ejercicio de implementar la función "parteEntera"
--       de la clase 3.

cantidad3Pseudoprimos :: Integer -> Integer
cantidad3Pseudoprimos n | n < 1 = 0
                        | esAPseudoprimo 3 n == False = cantidad3Pseudoprimos (n-1)
                        | otherwise = 1 + cantidad3Pseudoprimos (n-1)

-- EJERCICIO 4

-- Se implementa la funciónes auxiliares "es2y3Pseudoprimo" y "siguiente2y3Pseudoprimo"

es2y3Pseudoprimo :: Integer -> Bool
es2y3Pseudoprimo n | esAPseudoprimo 2 n && esAPseudoprimo 3 n = True                                           
                   | otherwise = False

siguiente2y3Pseudoprimo :: Integer -> Integer
siguiente2y3Pseudoprimo n | es2y3Pseudoprimo (n+1) == True = (n+1)
                          | otherwise = siguiente2y3Pseudoprimo (n+1)

-- Finalmente se implementa la función "siguiente2y3Pseudoprimo"
-- NOTA: Se toma de caso base al número 1105 ya que es el primer término
--       que es 2-Pseudoprimo y 3-Pseudoprimo a la vez.                           

kesimo2y3Pseudoprimo :: Integer -> Integer
kesimo2y3Pseudoprimo 1 = 1105 
kesimo2y3Pseudoprimo n = siguiente2y3Pseudoprimo (kesimo2y3Pseudoprimo (n-1))

-- EJERCICIO 5

-- Se implementa la función auxiliar "esCarmichaelDesde"
-- NOTA: Si "a" y "n" no son coprimos no tiene que evaluar, por eso "a" avanza a "a+1".
--       Luego si son coprimos recién evalúa la condición: "n" es "a"-pseudoprimo, si no cumple es resultado es False 
--       y si es a-pseudoprimo: "a" avanza a "a+1" y continua evaluando (1 <= a <= n-1).
--       Si "a" llega a "n-1" cumpliendo las condiciones anteriores, ya sea si "n" y "n-1" no son coprimos ó si son
--       coprimos y "n" es (n-1)-pseudoprimo, "n" es un número de Carmichael y el resultado es True                                            

esCarmichaelDesde :: Integer -> Integer -> Bool
esCarmichaelDesde a n | a == n = True
                      | (sonCoprimos a n == False) = esCarmichaelDesde (a+1) n
                      | (esAPseudoprimo a n == True) = esCarmichaelDesde (a+1) n
                      | otherwise = False

-- Se implementa la función "esCarmichael"
-- NOTA: Se aplica la restricción: "n < 4 = False", ya que 4 es el menor de los
--       números compuestos (naturales).                      

esCarmichael :: Integer -> Bool
esCarmichael n | n < 4 = False
               | otherwise = esCarmichaelDesde 1 n