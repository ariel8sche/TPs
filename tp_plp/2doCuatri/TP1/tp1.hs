{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use second" #-}
module Proceso (Procesador, AT (Nil, Tern), RoseTree (Rose), Trie (TrieNodo), foldAT, foldRose, foldTrie, procVacio, procId, procCola, procHijosRose, procHijosAT, procRaizTrie, procSubTries, unoxuno, sufijos, inorder, preorder, postorder, preorderRose, hojasRose, ramasRose, caminos, palabras, ifProc, (++!), (.!)) where

import Data.Maybe
import Test.HUnit

-- Definiciones de tipos

type Procesador a b = a -> [b]

-- Árboles ternarios
data AT a = Nil | Tern a (AT a) (AT a) (AT a) deriving (Eq)

-- E.g., at = Tern 1 (Tern 2 Nil Nil Nil) (Tern 3 Nil Nil Nil) (Tern 4 Nil Nil Nil)
-- Es es árbol ternario con 1 en la raíz, y con sus tres hijos 2, 3 y 4.

-- RoseTrees
data RoseTree a = Rose a [RoseTree a] deriving (Eq)

-- E.g., rt = Rose 1 [Rose 2 [], Rose 3 [], Rose 4 [], Rose 5 []]
-- es el RoseTree con 1 en la raíz y 4 hijos (2, 3, 4 y 5)

-- Tries
data Trie a = TrieNodo (Maybe a) [(Char, Trie a)] deriving (Eq)

-- E.g., t = TrieNodo (Just True) [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])]
-- es el Trie Bool de que tiene True en la raíz, tres hijos (a, b, y c), y, a su vez, b tiene como hijo a d.

-- Definiciones de Show

instance (Show a) => Show (RoseTree a) where
  show = showRoseTree 0
    where
      showRoseTree :: (Show a) => Int -> RoseTree a -> String
      showRoseTree indent (Rose value children) =
        replicate indent ' '
          ++ show value
          ++ "\n"
          ++ concatMap (showRoseTree (indent + 2)) children

instance (Show a) => Show (AT a) where
  show = showAT 0
    where
      showAT :: (Show a) => Int -> AT a -> String
      showAT _ Nil = replicate 2 ' ' ++ "Nil"
      showAT indent (Tern value left middle right) =
        replicate indent ' '
          ++ show value
          ++ "\n"
          ++ showSubtree (indent + 2) left
          ++ showSubtree (indent + 2) middle
          ++ showSubtree (indent + 2) right

      showSubtree :: (Show a) => Int -> AT a -> String
      showSubtree indent subtree =
        case subtree of
          Nil -> replicate indent ' ' ++ "Nil\n"
          _ -> showAT indent subtree

instance (Show a) => Show (Trie a) where
  show = showTrie ""
    where
      showTrie :: (Show a) => String -> Trie a -> String
      showTrie indent (TrieNodo maybeValue children) =
        let valueLine = case maybeValue of
              Nothing -> indent ++ "<vacío>\n"
              Just v -> indent ++ "Valor: " ++ show v ++ "\n"
            childrenLines = concatMap (\(c, t) -> showTrie (indent ++ "  " ++ [c] ++ ": ") t) children
         in valueLine ++ childrenLines

-- Ejercicio 1
procVacio :: Procesador a b
procVacio = const []

procId :: Procesador a a
procId x = [x]

procCola :: Procesador [a] a
procCola [] = []
procCola (_ : xs) = xs

procHijosRose :: Procesador (RoseTree a) (RoseTree a)
procHijosRose (Rose _ h) = h

procHijosAT :: Procesador (AT a) (AT a)
procHijosAT Nil = []
procHijosAT (Tern v i m d) = [i] ++ [m] ++ [d]

procRaizTrie :: Procesador (Trie a) (Maybe a)
procRaizTrie (TrieNodo v _) = [v]

procSubTries :: Procesador (Trie a) (Char, Trie a)
procSubTries (TrieNodo _ n) = n

-- Ejercicio 2

foldAT :: b -> (a -> b -> b -> b -> b) -> AT a -> b
foldAT b f at = case at of
  Nil -> b
  Tern v i m d -> f v (rec i) (rec m) (rec d)
  where
    rec = foldAT b f

foldRose :: (a -> [b] -> b) -> RoseTree a -> b
foldRose f (Rose v vs) = f v (map (foldRose f) vs)

foldTrie :: (Maybe a -> [(Char, b)] -> b) -> Trie a -> b
foldTrie f (TrieNodo mayb xs) = f mayb (map (\(c, t) -> (c, foldTrie f t)) xs)

-- Ejercicio 3
unoxuno :: Procesador [a] [a]
unoxuno = map (\x -> [x])

sufijos :: Procesador [a] [a]
sufijos p = [drop n p | n <- [0..length p]] 

--Ejercicio 4
preorder :: AT a -> [a]
preorder = foldAT [] (\r i m d -> [r] ++ i ++ m ++ d)

inorder :: AT a -> [a]
inorder = foldAT [] (\r i m d -> i ++ m ++ [r] ++ d)

postorder :: AT a -> [a]
postorder = foldAT [] (\r i m d -> i ++ m ++ d ++ [r])

-- Ejercicio 5

preorderRose :: Procesador (RoseTree a) a
preorderRose = foldRose (\n h -> [n] ++ concat h)


hojasRose :: Procesador (RoseTree a) a
hojasRose = foldRose (\n h -> if null h then [n] else concat h)
ramasRose :: Procesador (RoseTree a) [a]
ramasRose = foldRose (\n h -> if null h then [[n]] else map (n:) (concat h))

-- Ejercicio 6
caminos :: Procesador (Trie a) [Char]
caminos = foldTrie (\_ xs -> "" : concatMap (\(c, t) -> map (c :) t) xs)

-- Ejercicio 7
palabras :: Procesador (Trie a) [Char]
palabras = foldTrie (\mayb xs -> if isJust mayb then "" : concatMap (\(c, t) -> map (c :) t) xs else concatMap (\(c, t) -> map (c :) t) xs)

-- Ejercicio 8
-- 8.a)
ifProc :: (a -> Bool) -> Procesador a b -> Procesador a b -> Procesador a b
ifProc f a b t = if f t then a t else b t

-- 8.b)
(++!) :: Procesador a b -> Procesador a b -> Procesador a b
(++!) f g t = f t ++ g t

-- 8.c)
(.!) :: Procesador b c -> Procesador a b -> Procesador a c
(.!) f g t  = concatMap f (g t)

-- Otra Forma:  (.!) f g t  = foldr (\x rec -> f x ++ rec) [] (g t)

-- Ejercicio 9
-- Se recomienda poner la demostración en un documento aparte, por claridad y prolijidad, y, preferentemente, en algún formato de Markup o Latex, de forma de que su lectura no sea complicada.

{-Tests-}

main :: IO Counts
main = do runTestTT allTests

-- estructuras para testear:
-- Casos para AT:
at = Tern 1 (Tern 2 Nil Nil Nil) (Tern 3 Nil Nil Nil) (Tern 4 Nil Nil Nil)
ats = [Tern 1 (Tern 2 Nil Nil Nil) (Tern 3 Nil Nil Nil) (Tern 4 Nil Nil Nil), Tern 9 (Tern 10 Nil Nil Nil) (Tern 12 (Tern 13 Nil Nil Nil) Nil Nil) (Tern 19 Nil Nil Nil)]
atConNietos = Tern 1 (Tern 2 Nil (Tern 20 Nil Nil Nil) Nil) (Tern 3 Nil Nil (Tern 30 Nil Nil Nil)) (Tern 4 (Tern 40 Nil Nil Nil) Nil Nil)
atSinHijos = Tern 1 Nil Nil Nil
atTipoString = Tern "dou" (Tern "aaaa" Nil Nil Nil) (Tern "lol" Nil Nil Nil) (Tern "hoogle" Nil Nil Nil)
atNil = Nil
-- Casos para RoseTree:
rt = Rose 1 [Rose 2 [], Rose 3 [], Rose 4 [], Rose 5 []]
rts = [Rose 1 [Rose 2 [], Rose 3 [], Rose 4 [], Rose 5 []],Rose 0 [Rose 9 [], Rose 69 [], Rose 42 [], Rose 20 []] ]
rtConNietos = Rose 1 [Rose 2 [Rose 20 [], Rose 30 [], Rose 40 [], Rose 50 []], Rose 3 [], Rose 4 [], Rose 5 []]
rtSinHijos = Rose 1 []
rtTipoString = Rose "ola" [Rose "Soy" [], Rose "Una" [], Rose "Rosa" []]

-- Casos para Trie:
t = TrieNodo (Just True) [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])]
tSinHijos = TrieNodo (Just True) []
tRaizConNothing = TrieNodo Nothing [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])]
tTodoNothing = TrieNodo Nothing [('a', TrieNodo Nothing []), ('b', TrieNodo Nothing [('a', TrieNodo Nothing [('d', TrieNodo Nothing [])])]), ('c', TrieNodo Nothing [])]
ts = [TrieNodo (Just True) [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])], TrieNodo (Just True) [('d', TrieNodo (Just True) []), ('d', TrieNodo Nothing [('i', TrieNodo (Just True) [('a', TrieNodo Nothing [('v', TrieNodo (Just True) [('l', TrieNodo (Just True) [('o', TrieNodo (Just True) [])])])])])]), ('c', TrieNodo (Just True) [])]]

listaVacia = []
listaUnElem = [8]
listaNum = [1,2,3,4]
listaListaNum = [[10,9,24],[19,11,23,1],[18,12,22]]
listaStrings = ["lol", "aaaa", "vim"]
palabra = "Plp"
letra = "a"
palabraVacia = ""

allTests =
  test
    [ -- Reemplazar los tests de prueba por tests propios
      "ejercicio1" ~: testsEj1,
      "ejercicio2" ~: testsEj2,
      "ejercicio3" ~: testsEj3,
      "ejercicio4" ~: testsEj4,
      "ejercicio5" ~: testsEj5,
      "ejercicio6" ~: testsEj6,
      "ejercicio7" ~: testsEj7,
      "ejercicio8a" ~: testsEj8a,
      "ejercicio8b" ~: testsEj8b,
      "ejercicio8c" ~: testsEj8c
    ]

-- Se testea para cada estructura recursiva definida
testsEj1 = test [
    procVacio at ~=? ([]::[Int]),
    procVacio rt ~=? ([]::[Int]),
    procVacio t ~=? ([]::[Int]),
    procVacio listaNum ~=? ([]::[Int]),
    procVacio listaStrings ~=? ([]::[Int]),
    procId at ~=? [at],
    procId t ~=? [t],
    procId rt ~=? [rt],
    procId listaNum ~=? [listaNum],
    procId listaStrings ~=? [listaStrings],
    procId listaVacia ~=? [[]::[Int]],
    procCola ats ~=? tail ats,
    procCola rts ~=? tail rts,
    procCola ts ~=? tail ts,
    procCola listaNum ~=? tail listaNum,
    procCola listaStrings ~=? tail listaStrings,
    procCola listaVacia ~=? ([]::[Int]),
    procHijosRose rt ~=? [Rose 2 [], Rose 3 [], Rose 4 [], Rose 5 []],
    procHijosRose rtConNietos ~=? [Rose 2 [Rose 20 [], Rose 30 [], Rose 40 [], Rose 50 []], Rose 3 [], Rose 4 [], Rose 5 []],
    procHijosRose rtSinHijos ~=? [],
    procHijosRose rtTipoString ~=? [Rose "Soy" [], Rose "Una" [], Rose "Rosa" []],
    procHijosAT at ~=? [Tern 2 Nil Nil Nil,  Tern 3 Nil Nil Nil,  Tern 4 Nil Nil Nil],
    procHijosAT atConNietos ~=? [Tern 2 Nil (Tern 20 Nil Nil Nil) Nil, Tern 3 Nil Nil (Tern 30 Nil Nil Nil), Tern 4 (Tern 40 Nil Nil Nil) Nil Nil],
    procHijosAT atSinHijos ~=? [Nil, Nil, Nil],
    procHijosAT atTipoString ~=? [Tern "aaaa" Nil Nil Nil,  Tern "lol" Nil Nil Nil,  Tern "hoogle" Nil Nil Nil],
    procRaizTrie t ~=? [Just True],
    procRaizTrie tRaizConNothing ~=? [Nothing],
    procSubTries t ~=? [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])],
    procSubTries tRaizConNothing ~=? [('a', TrieNodo (Just True) []), ('b', TrieNodo Nothing [('a', TrieNodo (Just True) [('d', TrieNodo Nothing [])])]), ('c', TrieNodo (Just True) [])],
    procSubTries tSinHijos ~=? []
    ]

testsEj2 =
  test [
  foldAT Nil (\r i m d -> Tern (r+1) i m d) at ~=? Tern 2 (Tern 3 Nil Nil Nil) (Tern 4 Nil Nil Nil) (Tern 5 Nil Nil Nil),
  foldAT Nil (\r i m d -> Tern (r+1) i m d) atSinHijos ~=? Tern 2 Nil Nil Nil,
  foldAT Nil (\r i m d -> Tern (r+1) i m d) atNil ~=? Nil,
  foldRose (\r h -> Rose (r+1) h) rt ~=? Rose 2 [Rose 3 [], Rose 4 [], Rose 5 [], Rose 6 []],
  foldRose (\r h -> Rose (r+1) h) rtSinHijos ~=? Rose 2 [],
    foldTrie (\m xs -> sum (map (\(c,r) -> r+1) xs)) t ~=? 5 -- cuenta todos los hijos desde la raiz
    ]

testsEj3 =
  test
    [ unoxuno palabraVacia
        ~=? [],
      unoxuno letra
        ~=? ["a"],
      unoxuno palabra
        ~=? ["P","l","p"],
      unoxuno listaVacia
        ~=? ([] :: [[Int]]),
      unoxuno listaUnElem
        ~=? [[8]],
      unoxuno listaNum
        ~=? [[1],[2],[3],[4]],
      unoxuno listaListaNum
        ~=? [[[10,9,24]],[[19,11,23,1]],[[18,12,22]]],
      sufijos palabraVacia
        ~=? [""],
      sufijos letra
        ~=? ["a",""],
      sufijos palabra
        ~=? ["Plp","lp","p",""],
      sufijos listaVacia
        ~=? ([[]] :: [[Int]]),
      sufijos listaUnElem
        ~=? [[8],[]],
      sufijos listaNum
        ~=? [[1,2,3,4],[2,3,4],[3,4],[4],[]],
      sufijos listaListaNum
        ~=? [[[10,9,24],[19,11,23,1],[18,12,22]],[[19,11,23,1],[18,12,22]],[[18,12,22]],[]]
    ]

testsEj4 =
  test
    [ preorder atSinHijos
        ~=? [1],
      preorder atTipoString
        ~=? ["dou","aaaa","lol","hoogle"],
      preorder at
        ~=? [1,2,3,4],
      preorder atConNietos
        ~=? [1,2,20,3,30,4,40],
      inorder atSinHijos
        ~=? [1],
      inorder atTipoString
        ~=? ["aaaa","lol","dou","hoogle"],
      inorder at
        ~=? [2,3,1,4],
      inorder atConNietos
        ~=? [20,2,3,30,1,40,4],
      postorder atSinHijos
        ~=? [1],
      postorder atTipoString
        ~=? ["aaaa","lol","hoogle","dou"],
      postorder at
        ~=? [2,3,4,1],
      postorder atConNietos
        ~=? [20,2,30,3,40,4,1]
    ]

testsEj5 =
  test
    [ preorderRose rt ~=? [1,2,3,4,5],
    preorderRose rtConNietos ~=? [1,2,20,30,40,50,3,4,5],
    preorderRose rtSinHijos ~=? [1],
    preorderRose rtTipoString ~=? ["ola", "Soy", "Una", "Rosa"]
    ]

testsEj6 =
  test
    [ caminos t  ~=? ["","a","b","ba","bad","c"],
    caminos tSinHijos  ~=? [""],
    caminos tRaizConNothing ~=? ["","a","b","ba","bad","c"]
    ]

testsEj7 =
  test
  [ palabras t ~=? ["", "a", "ba", "c"],
  palabras tSinHijos ~=? [""], -- como tSinHijos tiene el valor (Just True) devuelve ""
  palabras tRaizConNothing ~=? ["a", "ba", "c"],
  palabras tTodoNothing ~=? []
  ]

testsEj8a =
  test
    [ ifProc even (const "Es par") (const "Es impar") 2
        ~=? "Es par",
      ifProc even (const "Es par") (const "Es impar") 5
        ~=? "Es impar",
      ifProc (== (Nil :: AT Int)) procVacio procId atNil
        ~=? [],
      ifProc (== (Nil :: AT Int)) procVacio procId at
        ~=? [at],
      ifProc (== (Nil :: AT Int)) procVacio preorder at
        ~=? [1,2,3,4],
      ifProc (null . procHijosRose) procId procVacio rtSinHijos
        ~=? [rtSinHijos]
    ]

testsEj8b =
  test
    [ (procId ++! (procId . map (+4))) listaNum
        ~=? [[1,2,3,4],[5,6,7,8]],
      (postorder ++! preorder) at
        ~=? [2,3,4,1,1,2,3,4],
      ((unoxuno . preorderRose) ++! (reverse . (sufijos . preorderRose))) rt
        ~=? [[1],[2],[3],[4],[5],[],[5],[4,5],[3,4,5],[2,3,4,5],[1,2,3,4,5]],
      (caminos ++! palabras) t
        ~=? ["","a","b","ba","bad","c","","a","ba","c"],
      (caminos ++! (reverse . caminos)) t
        ~=? ["","a","b","ba","bad","c","c","bad","ba","b","a",""]
    ]

testsEj8c =
  test
    [ ((\z->[0..z]) .! (map (+1))) [1,3]
        ~=? [0,1,2,0,1,2,3,4],
      ((\z->[0..z]) .! preorder ) at
        ~=? [0,1,0,1,2,0,1,2,3,0,1,2,3,4],
      (unoxuno .! (.) sufijos hojasRose) rt
        ~=? [[2],[3],[4],[5],[3],[4],[5],[4],[5],[5]],
        -- a cada elemento de la lista caminos t, se le agrega al final el terminador null,
        -- separados por ", "
        ((\z -> z++"\0, ") .! caminos) t ~=? "\NUL, a\NUL, b\NUL, ba\NUL, bad\NUL, c\NUL, "
    ]
