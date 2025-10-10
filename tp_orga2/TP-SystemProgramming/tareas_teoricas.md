# Preguntas Teóricas sobre Manejo de Tareas en x86

## 1. Si queremos definir un sistema que utilice sólo dos tareas, ¿Qué nuevas estructuras, cantidad de nuevas entradas en las estructuras ya definidas, y registros tenemos que configurar? ¿Qué formato tienen? ¿Dónde se encuentran almacenadas?
Para una tarea las estructura nuevas que necesitamos son un directorio, con al menos dos entradas. Una de las entradas sería para poder tener mapeadas las páginas de kernel y otra para poder tener mapeado su espacio de ejecución: código, datos y pila. En el caso de la entrada para kernel apuntaría a la page table que tiene todas sus entradas definidas, mientras que la otra entrada que apunta al espacio de ejecución, no necesariamente, pero si requería un mínimo de de 3 páginas lo que serían 3 entradas en la page table. Para la otra tarea necesitaríamos exactamente lo mismo.
La GDT está almacenada en la parte de kernel, al igual que los directorios, las tablas de página, código de la tarea y la memoria shared. Las páginas para la pila se encuentran entre las direcciones 0x400000 y 0x2ffffff, que es la memoria física almacenada para las tareas
También se necesitaría dos nuevas entradas en la GDT, una para cada TSS de las tareas, serían 2 estructuras nuevas. Estas estructuras estarían en direcciones mapeadas en la zona de kernel, para poder ser accedidas sin importar que directorio de páginas sea el actual.
Luego el task register debería setearse con el valor de alguna de estas dos tareas.

## 2. ¿A qué llamamos cambio de contexto? ¿Cuándo se produce? ¿Qué efecto tiene sobre los registros del procesador? Expliquen en sus palabras que almacena el registro TR y cómo obtiene la información necesaria para ejecutar una tarea después de un cambio de contexto.
Llamamos cambio de contexto al proceso de cambiar de la tarea que está en ejecución a otra que no. Se produce, en el caso de nuestro sistema, luego de una interrupción de reloj.
El efecto que tiene sobre los registros es que los setea varios con los valores que estaban almacenados en la TSS, por ejemplo, todos los registros de propósito general, cr3, todos los registros de segmento, etc.
El registro TR almacena, en su parte visible, el selector de segmento de la GDT que contiene la dirección física base de la TSS. La parte invisible almacena la dirección base y el límite del segmento de la TSS.
La información necesaria para ejecutar una tarea luego del cambio de contexto se obtiene de la TSS (contexto de ejecución) y el espacio de ejecución del registro CR3, que se obtiene también de la TSS.

## 3. Al momento de realizar un cambio de contexto el procesador va almacenar el estado actual de acuerdo al selector indicado en el registro TR y ha de restaurar aquel almacenado en la TSS cuyo selector se asigna en el jmp far. ¿Qué consideraciones deberíamos tener para poder realizar el primer cambio de contexto? ¿Y cuáles cuando no tenemos tareas que ejecutar o se encuentran todas suspendidas?
Se debería tener una tarea inicial, ya que el cambio de contexto es entre dos tareas, y si el TR no apunta a una TSS válida cuando se busque dicha TSS para guardar el contexto actual se levantaría la excepción #TS (Invalid TSS).
Cómo en cada interrupción de reloj se intenta hacer un cambio de contexto se necesita tener una tarea a la cual saltar o quedarse si no hay otra tarea disponible, en caso contrario no tendríamos a qué saltar en el jmp far, por lo tanto se necesita la tarea 'idle' a la cual se salta cuando no hay otra tarea disponible.

## 4. ¿Qué hace el scheduler de un Sistema Operativo? ¿A qué nos referimos con que usa una política?
El scheduler define un criterio para decidir cual es la próxima tarea a ejecutar. Por política nos referimos al algoritmo que utiliza para poder decidir cuál será la próxima tarea y también durante cuánto tiempo. En nuestro caso la próxima tarea se define a partir de un orden fijo, y el mismo tiempo de ejecución para cada tarea.

## 5. En un sistema de una única CPU, ¿cómo se hace para que los programas parezcan ejecutarse en simultáneo?
Se cambia entre tareas rápidamente, millones de veces por segundo.

## 9. ¿Por qué hace falta tener definida la pila de nivel 0 en la TSS?
Es necesario ya que para atender una interrupción cuando se está ejecutando una tarea con nivel 3 el procesador hace un cambio de pila y lo tiene que hacer con una pila de nivel de privilegio igual a la interrupción, por lo que debe ser por una de nivel 0. El segmento de la pila y el stack pointer son obtenidos de la TSS, por lo que siempre tiene que estar ahí.

## 11. Estando definidas sched_task_offset y sched_task_selector:
```assembly
sched_task_offset: dd 0xFFFFFFFF
sched_task_selector: dw 0xFFFF
global _isr32  
_isr32:
  pushad ;se pushea los registros de propósito general para preservarlos
  call pic_finish1 ;se avisa al pic que la interrupción ya ha sido atendida
  call sched_next_task ;se llama al scheduler para que devuelva el selector de segmento de la siguiente tarea
  str cx ;se obtiene el valor del TR (la parte visible), que es el selector de segmento de la tarea actual 
  cmp ax, cx ;si ambos selectores son iguales es que es la misma tarea
  je .fin ;si son iguales entonces no es necesario cambiar de tarea, por lo tanto puedo saltar a fin
  mov word [sched_task_selector], ax ;llego acá si los selectores eran distintos, seteo el valor del selector al que voy a saltar
  jmp far [sched_task_offset] ;hago salto
.fin:
  popad
  iret
```

## b) En la línea que dice `jmp far [sched_task_offset]` ¿De qué tamaño es el dato que estaría leyendo desde la memoria? ¿Qué indica cada uno de estos valores? ¿Tiene algún efecto el offset elegido?
El tamaño es de 48 bits, los 32 bits más altos indican el selector de segmento, mientras que el offset son los más bajos, pero estos no tienen ningún efecto.

## c) ¿A dónde regresa la ejecución (EIP) de una tarea cuando vuelve a ser puesta en ejecución?
Regresa a la dirección de la siguiente instrucción.

## 12. Para este Taller la cátedra ha creado un scheduler que devuelve la próxima tarea a ejecutar.
### a) En los archivos `sched.c` y `sched.h` se encuentran definidos los métodos necesarios para el Scheduler. Expliquen cómo funciona el mismo, es decir, cómo decide cuál es la próxima tarea a ejecutar. Pueden encontrarlo en la función `sched_next_task`.
Para decidir cuál es la siguiente tarea a ejecutar, busca la primera tarea runnable a partir de la ID de la tarea actual (`current_task` en el código) (sin incluirla). Esto lo hace en un `for`, y cuando encuentra una ID relacionada a una tarea runnable, sale del `for` con un `break`. Luego actualiza `current_task` y devuelve el selector de la tarea elegida (que está en un array de structs indexado por los IDs de las tareas, `sched_tasks`). En el caso de que no haya una tarea runnable, devuelve el selector de la tarea idle.

## 14. a) ¿Qué está haciendo la función `tss_gdt_entry_for_task`?
Crea una entrada en la GDT para una TSS.

### b) ¿Por qué motivo se realiza el desplazamiento a izquierda de `gdt_id` al pasarlo como parámetro de `sched_add_task`?
`sched_add_task` es la función que setea las posiciones de `sched_tasks` correctamente, relacionando la ID de la tarea con su selector. Como el tipo de entrada que recibe es un selector, tiene que convertir `gdt_id` en uno de estos, por eso lo desplaza a izquierda.

## 15. Ejecuten las tareas en QEMU y observen el código de estas superficialmente.
### a) ¿Qué mecanismos usan para comunicarse con el kernel?
Se utilizan syscalls, que permiten a las tareas ejecutar codigo a nivel de kernel, en este caso en particular 
para poder printear en pantalla (el buffer de la pantalla está mapeado con nivel de privilegio supervisor)
### b) ¿Por qué creen que no hay uso de variables globales? ¿Qué pasaría si una tarea intentase escribir en su .data con nuestro sistema?
No hay uso de variables globales porque no mapeamos paginas para este uso. En nuestro kernel definimos paginas para pila, codigo y memoria compartida. Si una tarea intentáse escribir en su .data se levantaría una excepción, ya que se intentaría acceder a memoria que no esta mapeada.

## 16. Observen `tareas/task_prelude.asm`. El código de este archivo se ubica al principio de las tareas.
### a. ¿Por qué la tarea termina en un loop infinito?
Termina en un loop infinito para protegernos de la situación en la que el EIP apunte a una dirección virtual que no pertenece a la página de código. Si la tarea terminase de forma inesperada, con dicho loop sería imposible que esto suceda, ya que el EIP queda 'clavado' en esa dirección.
