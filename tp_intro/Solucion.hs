module Solucion where

-- Completar con los datos del grupo
--
-- Nombre de Grupo: KessokuGang
-- Integrante 1: Octavio Valentín Vives, valnrms@gmail.com, 822/22
-- Integrante 2: Ariel Eduardo Schenone Duarte, ariel8sche@gmail.com, 431/22
-- Integrante 3: Benjamin Scaffidi, benjascaf@gmail.com, 832/22
-- Integrante 4: Nahuel Ossvald, nossva@gmail.com, 166/22

type Usuario = (Integer, String) -- (id, nombre)
type Relacion = (Usuario, Usuario) -- usuarios que se relacionan
type Publicacion = (Usuario, String, [Usuario]) -- (usuario que publica, texto publicacion, likes)
type RedSocial = ([Usuario], [Relacion], [Publicacion])

-- Funciones basicas

usuarios :: RedSocial -> [Usuario]
usuarios (us, _, _) = us

relaciones :: RedSocial -> [Relacion]
relaciones (_, rs, _) = rs

publicaciones :: RedSocial -> [Publicacion]
publicaciones (_, _, ps) = ps

idDeUsuario :: Usuario -> Integer
idDeUsuario (id, _) = id

nombreDeUsuario :: Usuario -> String
nombreDeUsuario (_, nombre) = nombre

usuarioDePublicacion :: Publicacion -> Usuario
usuarioDePublicacion (u, _, _) = u

likesDePublicacion :: Publicacion -> [Usuario]
likesDePublicacion (_, _, us) = us

--Funciones auxiliares:

-- Da la longitud de una lista
longitud :: [t] -> Int
longitud [] = 0
longitud (x:xs) = longitud xs + 1

-- Ve si una lista está contenida en otra
listaContenida :: (Eq t) => [t] -> [t] -> Bool
listaContenida [] _ = True
listaContenida (x:xs) l = ((elem x l) && (listaContenida xs l))

-- Dada una lista de publicaciones y un usuario, se fija si el usuario le dio like a todas las publicaciones. Esto es siempre y cuando el usuario no sea el autor de la publicación.
-- likedPostsWOBeingAuthor: liked posts without being author
{- likedAllPosts me parece que queda mejor, y aclaramos que no puede ser el autor por como llamamos la funcion durante la recursion -}
likedPostsWOBeingAuthor :: [Publicacion] -> Usuario -> Bool
likedPostsWOBeingAuthor [] _ = True
likedPostsWOBeingAuthor (post:posts) user = (usuarioDePublicacion post /= user) && elem user (likesDePublicacion post) && likedPostsWOBeingAuthor posts user

-- Dada una lista con relaciones y un usuario, devuelve la lista de relaciones pero quitando todas las relaciones que tienen que ver con el usuario dado
removeRelations :: [Relacion] -> Usuario -> [Relacion]
removeRelations [] _ = []
removeRelations (relation:relations) user | fst relation == user || snd relation == user = removeRelations relations user
                                          | otherwise = relation:(removeRelations relations user)

-- Fin de funciones auxiliares

-- Ejercicios

-- Agarra la tupla RedSocial, ignorando las últimas dos coordenadas (relaciones y publicaciones) ya que no nos interesan para el comportamiento de nuestra función.
-- Luego, haciendo pattern matching recorremos la lista de usuario, asumiendo que tenemos el resto de la de usuarios dada (hipótesis) y sólamente nos falta un usuario (i.e. recursión)
-- Finalmente agregamos al usuario que falta a la lista dada.
nombresDeUsuarios :: RedSocial -> [String]
nombresDeUsuarios ([],_,_) = []
nombresDeUsuarios (user:users, relations, posts) = (nombreDeUsuario user):(nombresDeUsuarios (users,relations,posts))

-- Se fija en las relaciones, viendo si el usuario es parte de una de las duplas. Si es parte, entonces el otro elemento de la dupla es el amigo del usuario.
-- En caso de que no pertenezca a la dupla, el usuario no tiene nada que ver en esa relación; chequeamos la siguiente.
-- Si no hay relaciones o se recorrieron todas, caso base: [].
amigosDe :: RedSocial -> Usuario -> [Usuario]
amigosDe (_,[],_) _ = []
amigosDe (users, relation:relations, posts) user | fst relation == user = (snd relation):(amigosDe (users, relations, posts) user)
                                                 | snd relation == user = (fst relation):(amigosDe (users, relations, posts) user)
                                                 | otherwise = amigosDe (users, relations, posts) user

-- Aprovechando la función anterior, contamos los elementos de la lista que devuelve amigosDe.
cantidadDeAmigos :: RedSocial -> Usuario -> Int
cantidadDeAmigos socialNetwork user = longitud (amigosDe socialNetwork user)

-- Simil a alguna(s) funcion(es) que hemos programado en la guía práctica de ejercicios.
-- Compara el usuario actual con el que tiene más amigos del resto (hipótesis, podemos hacer esto con recursión en Haskell)
-- En caso de serlo, devolvemos el usuario. Caso contrario hacemos recursión.
-- Si no hay relaciones, va a devolver el primer usuario de la lista de usuarios.
usuarioConMasAmigos :: RedSocial -> Usuario
usuarioConMasAmigos ([user], _, _) = user
usuarioConMasAmigos (user:users, relations, posts) | cantidadDeAmigos socialNetwork user >= cantidadDeAmigos socialNetwork userWithTheMostFriends = user
                                                   | otherwise = userWithTheMostFriends
                                                   where socialNetwork = (user:users,relations,posts)
                                                         userWithTheMostFriends = usuarioConMasAmigos (users,relations,posts)

-- Se fija si está Roberto Carlos (i.e. si existe un usuario con más de un millón de amigos).
-- (Análogo: que el usuario con más amigos tiene más de un millón de amigos (10 amigos con la última update)).
estaRobertoCarlos :: RedSocial -> Bool
estaRobertoCarlos socialNetwork = cantidadDeAmigos socialNetwork robertoCarlos > 10
                                  where robertoCarlos = usuarioConMasAmigos socialNetwork

-- Itera 1x1 las publicaciones, al encontrar una publicación del autor la agrega a la lista de las otras publicaciones del autor (hipótesis para la recursión).
publicacionesDe :: RedSocial -> Usuario -> [Publicacion]
publicacionesDe (_,_,[]) _ = []
publicacionesDe (users, relations, post:posts) user | usuarioDePublicacion post == user = post:otherPostsFromAuthor
                                                    | otherwise = otherPostsFromAuthor
                                                    where otherPostsFromAuthor = publicacionesDe (users,relations,posts) user

-- Parecido al anterior. Recorre las publicaciones y se fija si le gustaron al usuario (es decir, que el usuario pertenece a la lista de likes), al encontrar una la agrega a la lista de las publicaciones que le gustaron al usuario (hipótesis para la recursión).
publicacionesQueLeGustanA :: RedSocial -> Usuario -> [Publicacion]
publicacionesQueLeGustanA (_,_,[]) _ = []
publicacionesQueLeGustanA (users, relations, post:posts) user | elem user (likesDePublicacion post) = post:otherLikedPostsByUser
                                                              | otherwise = otherLikedPostsByUser
                                                              where otherLikedPostsByUser = publicacionesQueLeGustanA (users, relations, posts) user

-- Este es divertido. Planteamos la doble inclusión de ambas listas como si de conjuntos se tratase.
-- Por lo que, dos listas A y B serán "iguales" (ignorando repetidos y orden) <=> A está contenida en B y B está contenida en A.
lesGustanLasMismasPublicaciones :: RedSocial -> Usuario -> Usuario -> Bool
lesGustanLasMismasPublicaciones socialNetwork user1 user2 = listaContenida (postsLikedBy user1) (postsLikedBy user2) && listaContenida (postsLikedBy user2) (postsLikedBy user1)
                                                            where postsLikedBy = publicacionesQueLeGustanA socialNetwork

-- Utilizando la función auxiliar "likedPostsWOBeingAuthor" (descripta arriba), para revisar si existe un usuario que le haya dado like a todas las publicaciones del autor.
-- Aprovechando la lógica de cortocircuito, usamos || (OR), es decir, revisa si un usuario es seguidor fiel del autor Ó otro usuario es seguidor fiel del autor Ó otro usuario...
-- En caso de que uno de verdadero, Haskell cortará la ejecución y devolverá verdadero.
-- En caso de que todos den falso, cae en el caso base que da falso (nos queda F || F || ... || F) que da falso.
tieneUnSeguidorFiel :: RedSocial -> Usuario -> Bool
tieneUnSeguidorFiel ([],_,_) _ = False
tieneUnSeguidorFiel (user:users, relations, posts) author | authorPosts == [] = False -- Por la especificación
                                                          | otherwise = likedPostsWOBeingAuthor authorPosts user || tieneUnSeguidorFiel (users, relations, posts) author
                                                          where authorPosts = publicacionesDe (user:users, relations, posts) author

-- La función existeSecuenciaDeAmigos verifica si existe una secuencia de amigos entre dos usuarios en la red social.
-- Usando pattern matching separamos en dos casos:
-- El caso base, donde no hay relaciones de amistad en la red social, y el caso recursivo, donde se eliminan relaciones de amistad para explorar otras posibles secuencias de amigos entre los usuarios.
-- Adjuntamos un imagen como ejemplo de la relación: [(u1,u2), (u1,u3), (u4,u2)].
existeSecuenciaDeAmigos :: RedSocial -> Usuario -> Usuario -> Bool
existeSecuenciaDeAmigos (_,[],_) _ _ = False
existeSecuenciaDeAmigos (users, relations, posts) user1 user2 = (tieneAmigos user1 && tieneAmigos user2) && (elem user2 (friend:friends) || existeSecuenciaDeAmigosSobreElRestoDeAmigos || existeSecuenciaDeAmigosDesdeAmigos)
                                                where (friend:friends) = amigosDe (users, relations, posts) user1
                                                      (firstFriendFriend:firstFriendFriends) = amigosDe (users, relations, posts) friend
                                                      existeSecuenciaDeAmigosSobreElRestoDeAmigos = existeSecuenciaDeAmigos (users, removeRelations relations user1, posts) friend user2
                                                      existeSecuenciaDeAmigosDesdeAmigos = existeSecuenciaDeAmigos (users, removeRelations relations friend, posts) firstFriendFriend  user2
                                                      tieneAmigos user = amigosDe (users, relations, posts) user /= []
