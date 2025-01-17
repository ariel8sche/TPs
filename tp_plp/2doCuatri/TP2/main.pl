%%%%%%%%%%%%%%%%%%%%%%%%
%% Predicados básicos %%
%%%%%%%%%%%%%%%%%%%%%%%%

%% Ejercicio 1
%% proceso(+P)
proceso(computar).
proceso(leer(_)).
proceso(escribir(_,_)).
proceso(paralelo(Proceso1,Proceso2)) :- proceso(Proceso1), proceso(Proceso2).
proceso(secuencia(Proceso1,Proceso2)) :- proceso(Proceso1), proceso(Proceso2).

%% Ejercicio 2
%% buffersUsados(+P,-BS)
% En base a que es el orden de BS
buffersUsados(computar,[]).
buffersUsados(escribir(Buffer,_),[Buffer]).
buffersUsados(leer(Buffer),[Buffer]).
buffersUsados(secuencia(Proceso1,Proceso2),ListaDeBuffersOrdenada) :- buffersUsados(Proceso1,ListaDeBuffersP1), buffersUsados(Proceso2,ListaDeBuffersP2), append(ListaDeBuffersP1, ListaDeBuffersP2, ListaDeBuffers), sort(ListaDeBuffers,ListaDeBuffersOrdenada).
buffersUsados(paralelo(Proceso1,Proceso2), ListaDeBuffersOrdenada) :- buffersUsados(Proceso1,ListaDeBuffersP1), buffersUsados(Proceso2,ListaDeBuffersP2), append(ListaDeBuffersP1, ListaDeBuffersP2, ListaDeBuffers), sort(ListaDeBuffers,ListaDeBuffersOrdenada).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Organización de procesos %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Ejercicio 3
%% intercalar(+XS,+YS,?ZS)
intercalar([], [], []).
intercalar([X|XS], YS, [X|ZS]) :- intercalar(XS, YS, ZS).
intercalar(XS, [Y|YS], [Y|ZS]) :- intercalar(XS, YS, ZS).

%% Ejercicio 4
%% serializar(+P,?XS)
serializar(computar, [computar]).
serializar(leer(Buffer), [leer(Buffer)]).
serializar(escribir(Buffer, Contenido), [escribir(Buffer,Contenido)]).
serializar(secuencia(Proceso1,Proceso2), ProcesosSerializados) :- serializar(Proceso1, P1Serializado), serializar(Proceso2,P2Serializado), append(P1Serializado,P2Serializado,ProcesosSerializados).
serializar(paralelo(Proceso1,Proceso2), ProcesosSerializados) :- serializar(Proceso1, P1Serializado), serializar(Proceso2, P2Serializado), intercalar(P1Serializado,P2Serializado,ProcesosSerializados).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Contenido de los buffers %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ejercicio 5
%% contenidoBuffer(+B,+ProcesoOLista,?Contenidos)
contenidoBuffer(_,[],[]).
contenidoBuffer(B,P,CS) :- serializar(P,S), contenidoBuffer(B,S,CS).
contenidoBuffer(B,LP,CS) :- sonProcesos(LP), sacarComputar(LP, S), sacarProcesosQueNoSonDeBuffer(S, B, L), 
    contenidoBufferSerializado(L,CS).

%% sonProcesos(+XS). Toma XS, una lista cualquiera. Devuelve true si cada elemento es un proceso.
sonProcesos([X]) :- proceso(X).
sonProcesos([X|XS]) :- proceso(X),sonProcesos(XS).

%% sacarComputar(+XS,-S). Devuelve en S la lista XS sin contener el proceso computar.
sacarComputar([],[]).
sacarComputar([X|XS], [X|S]) :- X \= computar, sacarComputar(XS,S).
sacarComputar([computar|XS],S) :- sacarComputar(XS,S).

%% sacarProcesosQueNoSonDeBuffer(+S,+B,-CS). Toma S, una serializacion, y un B buffer. 
%% Devuelve en CS los procesos que usan el buffer B.
sacarProcesosQueNoSonDeBuffer([], _, []).
sacarProcesosQueNoSonDeBuffer([escribir(B, C)|PS], B, [escribir(B, C)|LS]) :- sacarProcesosQueNoSonDeBuffer(PS, B, LS).
sacarProcesosQueNoSonDeBuffer([leer(B)|PS], B, [leer(B)|LS]) :- sacarProcesosQueNoSonDeBuffer(PS, B, LS).
sacarProcesosQueNoSonDeBuffer([escribir(X, _)|PS], B, LS) :- X \= B, sacarProcesosQueNoSonDeBuffer(PS, B, LS).
sacarProcesosQueNoSonDeBuffer([leer(X)|PS], B, LS) :- X \= B, sacarProcesosQueNoSonDeBuffer(PS, B, LS).

%% contenidoBufferSerializado(+S,-CS). Dada una serializacion S, devuelve en CS el contenidoBuffer. 
%% En este predicado se asume que se usa un solo buffer en toda la serializacion.
%% Cuando se encuentra un escribir, revisa que no haya un leer en la cola de la lista para poder devolverlo en CS.
%% Caso de haber un leer en la cola de la lista, la elimina y sigue con la cola.
contenidoBufferSerializado([],[]).
contenidoBufferSerializado([escribir(_, _)|PS],CS) :- 
  sacarProxLeer(PS, PS2),
  contenidoBufferSerializado(PS2,CS).
contenidoBufferSerializado([escribir(_, C)|PS],[C|CS]) :- 
  not(member(leer(_), PS)),
  contenidoBufferSerializado(PS,CS).

%% sacarProxLeer(+PS,-PS2). Devuelve en PS2 la lista PS sin un leer, el primero que encuentra desde el inicio de la lista.
%% Si no existe un leer, devuelve falso.
sacarProxLeer([leer(_)|PS], PS).
sacarProxLeer([escribir(B,C)|PS], [escribir(B,C)|CS]) :- sacarProxLeer(PS, CS).

%% Ejercicio 6
%% contenidoLeido(+ProcesoOLista,?Contenidos)
%% Si se le pasa un Proceso a ProcesoOLista, se serializa y se manda de nuevo a contenidoLeido.
%% Al recibir una lista, se crean dos lista L1 y L2, sublistas de LP, donde L1 no tendra un leer y L2 tiene como primer elemento un leer de un buffer cualquiera B.
%% Nos aseguramos de que L1 no contenga un leer con un not.
%% Luego, hacemos una division en L1, guardando en L1I la parte izquierda que contendra los escribir que no son del buffer B.
%% L1I tendria la parte izquierda de el primer escribir con buffer B, y L seria su parte derecha. Esto nos sirve para "eliminarlo" junto con el leer de B.
%% Nos aseguramos de que L1I no contenga un escribir del buffer B con un not.
%% Hacemos append L1I con L en LS, seria L1 sin el primer escribir de buffer B. Luego, append LS con L2D en H; L2D seria L2 sin el primer leer de buffer B. 
%% Finalmente, la parte recursiva de contenidoLeido(H,CS), donde H seria lo mismo que LP, en el mismo orden, pero sin el primer leer que se encuentra (en orden) y el escribir de
%% su buffer.
%% En el caso base, contenidoLeido(LP,[]), se verifica si LP es lista porque al pasar un proceso y es serializado, luego de la ultima serializacion
%% se trata de unificar con contenidoLeido(LP,[]) y como not(member(leer(_),LP)) da true si LP es un proceso que no sea leer(_), este devuelve una lista vacia aunque sea invalido.
%% Por eso, se verifica que LP sea lista. En el caso recursivo, contenidoLeido(LP,[C|CS]), no hace falta usar is_list ya que nunca podria unificar los distintos appends que hay con un proceso.
contenidoLeido(P,CS) :- serializar(P, LP), contenidoLeido(LP,CS).
contenidoLeido(LP,[]) :- is_list(LP), not(member(leer(_),LP)). 
contenidoLeido(LP,[C|CS]) :- append(L1,L2,LP), append([leer(B)], L2D, L2), append(L1I,[escribir(B,C)|L], L1), 
    not(member(escribir(B,_),L1I)), not(member(leer(_),L1)),
    append(L1I,L,LS), append(LS,L2D,H), contenidoLeido(H,CS).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Contenido de los buffers %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Ejercicio 7
%% esSeguro(+P)
esSeguro(secuencia(Proceso1,Proceso2)):- contenidoLeido(secuencia(Proceso1,Proceso2),_).
esSeguro(paralelo(Proceso1,Proceso2)):- buffersUsados(Proceso1,BuffersP1), buffersUsados(Proceso2,BuffersP2), intersection(BuffersP1, BuffersP2, I), I == [], contenidoLeido(Proceso1,_), contenidoLeido(Proceso2,_).

%% Ejercicio 8
%% ejecucionSegura(?XS,+BS,+CS)

%% Primero se genera una lista finita, luego se usa generarProcesos para que todos los elementos sean procesos. Este seria nuestro Generate.
%% Luego, realiza el testeo con contenidoLeido, ya que contenidoLeido es un predicado que falla si y solo si se lee un buffer vacio, que es lo que
%% queremos testear.
ejecucionSegura(XS,BS,CS) :- var(XS), desde2(0, L), length(XS, L), generarProcesos(XS,BS,CS), contenidoLeido(XS,_).
ejecucionSegura(XS,BS,CS) :- nonvar(XS), generarProcesos(XS,BS,CS), contenidoLeido(XS,_).

%% XS deberia de estar instanciado como una lista finita, sean sus elementos instanciados o no.
%% Como usamos member sobre BS y CS, ambos necesitan estar instanciados ya que member(?Elemento, +Lista).
%% generarProcesos(+XS, +BS, +CS)
generarProcesos([], _, _).
generarProcesos([computar|XS], BS, CS) :- generarProcesos(XS,BS,CS).
generarProcesos([escribir(B1,C2)|XS], BS, CS) :- member(B1, BS), member(C2, CS), generarProcesos(XS,BS,CS).
generarProcesos([leer(B1)|XS], BS, CS) :- member(B1, BS), generarProcesos(XS,BS,CS).

%% desde2(+X,?Y). Visto en clase
desde2(X,X).
desde2(X,Y) :- nonvar(Y), X < Y.
desde2(X,Y) :- var(Y), desde2(X,Z), Y is Z + 1.

%% 8.1. Analizar la reversibilidad de XS, justificando adecuadamente por qué el predicado se comporta como
%% lo hace.
% Miremos primero el caso de XS sin instanciar, yendo al caso:
% ejecucionSegura(XS,BS,CS) :- var(XS), desde2(0, L), length(XS, L), generarProcesos(XS,BS,CS), contenidoLeido(XS,_).
% XS pasa por length(?Lista, ?Longitud), como ?Lista, se le puede pasar XS sin instanciar. Luego, instanciaria una lista de elementos "vacios" o sin instanciar con la longitud L dada por
% desde2. Luego, XS entra a generarProcesos(XS,BS,CS) y XS intentara, primero, instanciarse con la regla generarProcesos([], _, _).
% Como arrancamos creando la lista XS con longitud 0 hasta L, es lo primero que instanciaria (XS=[]). En las demas reglas se entra cuando XS \= [],
% entonces, buscaria instanciar cada elemento sin instanciar de XS con los 3 distintos casos; computar, escribir(B1,C2), leer(B1).  
% Luego de instanciar un elemento, dependiendo el caso, el predicado buscaria que B1 pertenezca a BS y C2 a CS. Este proceso se repite por toda la lista de XS que 
% sabemos que es una lista finita de longitud L, por lo tanto esto en algún momento termina.
% Una vez XS esté instanciado, con sus elementos siendo procesos basicos, lo pasa a contenidoLeido(XS,_). 
% Sabiendo que contenidoLeido(+ProcesoOLista,?Contenido), como XS esta instanciado y _ es una variable anonima, sabemos que vale y esto termina. 
% Concluimos que se puede pasar XS sin instanciar en ejecucionSegura.
% Caso de XS instanciado, que iria al caso:
% ejecucionSegura(XS,BS,CS) :- nonvar(XS), length(XS, L), generarProcesos(XS,BS,CS), contenidoLeidoSerializado(XS,_).
% A diferencia del anterior caso, como tenemos ya el XS instanciado no nos hace falta instanciarlo con un desde2 y restringiendo su longitud. Ademas,
% si hubiesemos usado un desde2 con length, el predicado ejecucionSegura nos daria el primer resultado y si le pedimos otro estaria en un bucle infinito en
% desde2, tratando de buscar un numero distinto a la longitud de XS, pero que luego se rompe en length. Por esto se dividio en var y nonvar.
% Luego, este XS instanciado entra generarProcesos y ocurre algo muy parecido al caso de XS sin instanciar;
% buscaria unificar cada elemento de la lista con un proceso, teniendo en cuenta el BS y CS. Luego, entramos en contenidoLeido(XS,_), donde ocurre lo mismo que antes;
% como XS ya esta instanciado y _ es una variable anonima, vemos como cumple la reversibilidad.
% Concluimos que se puede pasar XS instanciado en ejecucionSegura.
% Finalmente, como podemos pasar un XS instanciado o sin instanciar, ejecucionSegura es reversible en XS, quedando: ejecucionSegura(?XS,+BS,+CS).



%%%%%%%%%%%
%% TESTS %%
%%%%%%%%%%%

% Se espera que completen con las subsecciones de tests que crean necesarias, más allá de las puestas en estos ejemplos

cantidadTestsBasicos(14). % Actualizar con la cantidad de tests que entreguen
testBasico(1) :- proceso(computar). 
testBasico(2) :- not(proceso(tierra)).                                                     
testBasico(3) :- proceso(escribir(1,pepe)).                                           
testBasico(4) :- proceso(leer(1)).                                                   
testBasico(5) :- proceso(secuencia(escribir(1,pepe),escribir(2,pipo))).              
testBasico(6) :- proceso(paralelo(secuencia(escribir(1,'hola'),escribir(1,'chau')),  
                 secuencia(escribir(2,'hallo'),escribir(2,'tch ̈uss')))).

testBasico(7) :- buffersUsados(computar, []).                                        
testBasico(8) :- buffersUsados(leer(1), [1]).                                        
testBasico(9) :- buffersUsados(escribir(1, hola), [1]).                             
testBasico(10) :- buffersUsados(secuencia(escribir(1,'hola'),leer(1)),[1]).  
testBasico(11) :- buffersUsados(secuencia(escribir(1,'hola'),leer(2)),[1, 2]).                                       
testBasico(12) :- buffersUsados(secuencia(escribir(1,'hola'),escribir(1,'chau')),[1]). 
testBasico(13) :- buffersUsados(                                                      
                 paralelo(secuencia(escribir(1,'hola'),escribir(1,'chau')),
                 secuencia(escribir(2,'hallo'),escribir(2,'tch ̈uss'))),
                 [1, 2]). % Pregunta si esto esta bien. Osea que de dos veces en ves de una.
testBasico(14) :- \+ buffersUsados(escribir(1, hola), []). 

cantidadTestsProcesos(10). % Actualizar con la cantidad de tests que entreguen
testProcesos(1) :- findall(CS, intercalar([],[],CS), R), R = [[]].  
testProcesos(2) :- findall(CS, intercalar([1],[a], CS), R), R = [[1,a],[a,1]].
testProcesos(3) :- findall(CS, intercalar([1,2],[a,b],CS), R), R = [[1, 2, a, b], [1, a, 2, b], [1, a, b, 2], [a, 1, 2, b], [a, 1, b, 2], [a, b, 1, 2]].
testProcesos(4) :- not(intercalar([1,2],[a,b], [2,1,a,b])).

testProcesos(5) :- serializar(computar,[computar]).
testProcesos(6) :- serializar(leer(1),[leer(1)]).
testProcesos(7) :- serializar(escribir(1,mundo),[escribir(1,mundo)]).
testProcesos(8) :- findall(CS, serializar(paralelo(leer(1),(secuencia(computar,leer(2)))), CS), R), R = [[leer(1), computar, leer(2)], [computar, leer(1), leer(2)], [computar, leer(2), leer(1)]].
testProcesos(9) :- findall(CS, serializar(paralelo(leer(1),leer(2)),CS), R), R = [[leer(1), leer(2)], [leer(2), leer(1)]].
testProcesos(10) :- not(serializar(computo,[])).

cantidadTestsBuffers(15). % Actualizar con la cantidad de tests que entreguen
testBuffers(1) :- findall(CS, 
  contenidoLeido(paralelo(secuencia(escribir(1,ola),escribir(2,adios)), secuencia(escribir(1,oladenuevo), escribir(2, adiosotravez))), CS), R), 
  R = [[],[],[],[],[],[]]. 
testBuffers(2) :- findall(CS, 
contenidoLeido(paralelo(escribir(1,ola), escribir(1,oladenuevo)), CS), R), R = [[],[]]. 
% solo escritura en secuencia
testBuffers(3) :- findall(CS, contenidoLeido(secuencia(escribir(1,ola),escribir(2,adios)), CS), R), R = [[]].
% solo proceso escritura
testBuffers(4) :- findall(CS, contenidoLeido(escribir(1,ola), CS), R), R = [[]].
% solo computar
testBuffers(5) :- findall(CS, contenidoLeido(computar, CS), R), R = [[]].
% se lee buffer invalido. Como leer buffer vacio no debe de generar solucion, no devuelve ni lista vacia.
testBuffers(6) :- findall(CS, contenidoLeido(leer(1), CS), R), R = [].
testBuffers(7) :- findall(CS, contenidoBuffer(1, [escribir(1,a), leer(1), escribir(1,b), leer(1)], CS), R), R = [[]]. 
% se lee de mas en un buffer
testBuffers(8) :- findall(CS, contenidoLeido([escribir(1, agua), escribir(2, sol), leer(1), leer(1)],CS), R), R = [].
% se lee todo un buffer
testBuffers(9) :- findall(CS, contenidoLeido([escribir(1, agua), escribir(1, sol), leer(1), leer(1), escribir(2, ja)],CS), R), R = [[agua,sol]].
% se lee bien en 1 buffer, pero no en otro
testBuffers(10) :- findall(CS, contenidoLeido([escribir(1, agua), escribir(1, sol), leer(1), leer(1),leer(2)],CS), R), R = [].
% se leen distintos buffers
testBuffers(11) :- findall(CS, contenidoLeido([computar, escribir(1, agua), escribir(2, aaa),computar, escribir(1, sol), leer(1), leer(1),leer(2),computar],CS), R), R = [[agua, sol, aaa]].
testBuffers(12) :- findall(CS, contenidoLeido(paralelo(secuencia(escribir(2,sol),leer(2)), secuencia(escribir(1,agua),leer(1))),CS), R), R = [[sol, agua], [sol, agua], [agua, sol], [sol, agua], [agua, sol], [agua, sol]].
testBuffers(13) :- findall(CS, contenidoLeido([escribir(1,b),escribir(1,c), leer(1)],CS), R), R = [[b]].
testBuffers(14) :- findall(CS, contenidoLeido([escribir(1,b),leer(1),escribir(1,c), leer(1)],CS), R), R = [[b,c]].
testBuffers(15) :- findall(CS, contenidoLeido([escribir(1,a),escribir(1,b),escribir(1,c), leer(1), leer(1)],CS), R), R = [[a,b]].

cantidadTestsSeguros(40).
testSeguros(1) :- esSeguro(secuencia(computar,computar)).
testSeguros(2) :- esSeguro(secuencia(computar,escribir(1,"tierra"))).
testSeguros(3) :- esSeguro(secuencia(escribir(1,"tierra"),computar)).
testSeguros(4) :- esSeguro(secuencia(escribir(1,"tierra"),escribir(1,"aire"))).
testSeguros(5) :- esSeguro(secuencia(escribir(1,"tierra"),escribir(2,"aire"))).
testSeguros(6) :- esSeguro(secuencia(escribir(1,"tierra"),leer(1))).
testSeguros(7) :- esSeguro(secuencia(escribir(1,"agua"),secuencia(escribir(1,"tierra"),leer(1)))).
testSeguros(8) :- esSeguro(secuencia(secuencia(escribir(1,"tierra"),leer(1)),escribir(1,"agua"))).
testSeguros(9) :- esSeguro(secuencia(secuencia(escribir(1,"tierra"),leer(1)),secuencia(escribir(2,"tierra"),leer(2)))).
testSeguros(10) :- not(esSeguro(secuencia(computar,leer(1)))).
testSeguros(11) :- not(esSeguro(secuencia(leer(1),computar))).
testSeguros(12) :- not(esSeguro(secuencia(leer(1),escribir(1,"tierra")))).
testSeguros(13) :- not(esSeguro(secuencia(leer(1),leer(2)))).
testSeguros(14) :- not(esSeguro(secuencia(escribir(1,"tierra"), secuencia(leer(1),leer(1))))).
testSeguros(15) :- not(esSeguro(secuencia(leer(2), secuencia(leer(1),leer(1))))).
testSeguros(16) :- not(esSeguro(secuencia(escribir(1,"tierra"), secuencia(leer(1),leer(2))))).
testSeguros(17) :- esSeguro(paralelo(computar,computar)).
testSeguros(18) :- esSeguro(paralelo(computar,escribir(1,"tierra"))).
testSeguros(19) :- esSeguro(paralelo(escribir(1,"tierra"),computar)).
testSeguros(20) :- esSeguro(paralelo(escribir(1,"tierra"),escribir(2,"agua"))).
testSeguros(21) :- esSeguro(paralelo(escribir(1,"tierra"),secuencia(escribir(2,"tierra"),leer(2)))).
testSeguros(22) :- esSeguro(paralelo(secuencia(escribir(2,"tierra"),leer(2)),escribir(1,"tierra"))).
testSeguros(23) :- esSeguro(paralelo(secuencia(escribir(2,"tierra"),leer(2)),secuencia(escribir(1,"agua"),leer(1)))).
testSeguros(24) :- esSeguro(paralelo(computar,computar)).
testSeguros(25) :- esSeguro(paralelo(computar,escribir(1,"tierra"))).
testSeguros(26) :- esSeguro(paralelo(escribir(1,"tierra"),computar)).
testSeguros(27) :- esSeguro(paralelo(escribir(1,"tierra"),escribir(2,"agua"))).
testSeguros(28) :- esSeguro(paralelo(escribir(2,sol),secuencia(escribir(1,agua),leer(1)))).
testSeguros(29) :- esSeguro(paralelo(secuencia(escribir(2,sol),leer(2)),secuencia(escribir(1,agua),leer(1)))).
testSeguros(30) :- not(esSeguro(paralelo(escribir(2,"tierra"),escribir(2,"agua")))).
testSeguros(31) :- not(esSeguro(paralelo(escribir(2,"tierra"),leer(2)))).
testSeguros(32) :- not(esSeguro(paralelo(escribir(2,"agua"), secuencia(escribir(2,"tierra"),leer(2))))).
testSeguros(33) :- ejecucionSegura([computar],[2,8],["agua","tierra"]).
testSeguros(34) :- ejecucionSegura([computar,escribir(8,"tierra")],[2,8],["agua","tierra"]).
testSeguros(35) :- ejecucionSegura([escribir(8,"agua"),escribir(2,"tierra")],[2,8],["agua","tierra"]).
testSeguros(36) :- ejecucionSegura([escribir(2,"tierra"),leer(2)],[2,8],["agua","tierra"]).
testSeguros(37) :- ejecucionSegura([escribir(8,"agua"),computar,escribir(8,"tierra"),leer(8),computar,leer(8)],[2,8],["agua","tierra"]).
testSeguros(38) :- not(ejecucionSegura([computar,leer(8)],[2,8],["agua","tierra"])).
testSeguros(39) :- not(ejecucionSegura([escribir(2,"tierra"),leer(8),computar,leer(2)],[2,8],["agua","tierra"])).
testSeguros(40) :- not(ejecucionSegura([computar,leer(2),computar,leer(8),escribir(2,"tierra")],[2,8],["agua","tierra"])).


tests(basico) :- cantidadTestsBasicos(M), forall(between(1,M,N), testBasico(N)).
tests(procesos) :- cantidadTestsProcesos(M), forall(between(1,M,N), testProcesos(N)).
tests(buffers) :- cantidadTestsBuffers(M), forall(between(1,M,N), testBuffers(N)).
tests(seguros) :- cantidadTestsSeguros(M), forall(between(1,M,N), testSeguros(N)).

tests(todos) :-
  tests(basico),
  tests(procesos),
  tests(buffers),
  tests(seguros).

tests :- tests(todos).
