# Preguntas Teóricas

## a. ¿Cuántos niveles de privilegio podemos definir en las estructuras de paginación?
Se pueden definir dos niveles de privilegio:
1. **Supervisor mode**: Es el más privilegiado, contiene código del sistema (kernel, drivers, etc.) y datos del sistema (como page tables).
2. **User mode**: Para código y datos de aplicaciones.

## b. ¿Cómo se traduce una dirección lógica en una dirección física?
¿Cómo participan la dirección lógica, el registro de control CR3, el directorio y la tabla de páginas? Recomendación: describan el proceso en pseudocódigo.

Una dirección lógica primero se traduce a una dirección lineal, la cual se divide en tres partes y se relacionan de la siguiente forma:
- **Directory (bits 31 a 22)**: Es un offset en el page directory, que sumado a la dirección base del Page Directory (dirección física que está en los 20 bits más altos del registro CR3) permite obtener la dirección base de una Page Table.
- **Table (bits 21 a 12)**: Offset de una Page Table que se obtiene con lo anterior. Con este offset se selecciona una entrada de la Page Table que contiene la dirección física donde empieza la página.
- **Offset (bits 11 a 0)**: Offset dentro de la página, que sumado a la dirección base de la página, se obtiene la dirección física.

## c. ¿Cuál es el efecto de los siguientes atributos en las entradas de la tabla de página?
- **D (Dirty)**: Indica si se ha escrito en la página que referencia la entrada.
- **A (Accessed)**: Indica si se ha accedido a la página.
- **PCD (Page Level Cache Disable)**: Indica el tipo de memoria usada para acceder a la página. Cuando está seteado en 1, no se utiliza la TLB para guardar información sobre la traducción de la dirección lineal a la física de la página.
- **PWT (Page Level Write Through)**: Define la política de cache del procesador para una página específica (Write-Through o Write-Back).
- **U/S (User/Supervisor)**: Determina el nivel de privilegio de la página. Si está seteado en 0, no puede accederse con nivel de usuario.
- **R/W (Read/Write)**: Si es 0, la escritura no está permitida.
- **P (Present)**: Indica si está en memoria.

## d. ¿Qué sucede si los atributos U/S y R/W del directorio y de la tabla de páginas difieren? ¿Cuáles terminan siendo los atributos de una página determinada en ese caso?
- Si difieren en el atributo U/S, la tabla o bien el directorio de páginas tienen nivel de privilegio Supervisor.
- Si difieren en el atributo R/W y CR0.WP = 0 (desactiva la protección de escritura en nivel supervisor), entonces si la PDE y la PTE tienen nivel de privilegio de usuario, si alguno de los dos indica que la página es Read-Only, entonces el atributo final de la página es Read-Only. Si alguno de los dos tiene nivel de privilegio supervisor, el atributo final de la página será Read-Write.
- Para el caso en que CR0.WP = 1, entonces si la PTE o bien la PDE son Read-Only, el atributo final de la página será Read-Only. Solo será Read-Write si ambos tienen ese atributo.

## e. Suponiendo que el código de la tarea ocupa dos páginas y que utilizaremos una página para la pila de la tarea. ¿Cuántas páginas hace falta pedir a la unidad de manejo de memoria para el directorio, tablas de páginas y la memoria de una tarea?
Para cada tarea hay un único directorio de páginas, por lo tanto, solo necesito pedir una página. Cada tabla de páginas puede referenciar a 1024 páginas, por lo que solo necesito pedir una tabla de páginas. Para el código y la pila necesito pedir 3 páginas.

## f. ¿Qué es el buffer auxiliar de traducción (Translation Lookaside Buffer o TLB)?
La TLB es un caché que contiene información sobre la traducción de la dirección lineal a la física. La TLB mapea Page Number (bits 31:22 de la dirección lineal) a Page Frames (bits de la dirección física donde inicia la página). También contiene la información sobre los atributos finales de cada página.

### ¿Por qué es necesario purgarlo (tlbflush) al introducir modificaciones a nuestras estructuras de paginación (directorio, tabla de páginas)?
Es necesario ya que la TLB no modifica/borra automáticamente las entradas que hacen referencia a las estructuras modificadas en memoria. Por esta razón, para asegurar que las entradas de la TLB referencien a las estructuras modificadas, hay que borrarlas para que luego sean cacheadas nuevamente con las modificaciones.

### ¿Qué atributos posee cada traducción en la TLB?
Como se dijo antes, posee la dirección física del inicio de la página (Page Frame). También incluye los atributos de:
- Dirty
- Memory type (si se cachea en la TLB la traducción de la dirección lineal)

Y además incluye los atributos finales de:
- R/W
- U/S

### Al desalojar una entrada determinada de la TLB, ¿se ve afectada la homóloga en la tabla original para algún caso?
Si se modifica el atributo Dirty o Accesed de 1 a 0 de la entrada de la TLB, esto no se ve reflejado en memoria, por lo que se debe invalidar estas entradas de la TLB y en esos casos hay que modificar la tabla original con estos valores para que la modificación luego pueda ser cacheada nuevamente.
