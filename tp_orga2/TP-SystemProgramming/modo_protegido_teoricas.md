# Procesadores Intel: Modo Real y Modo Protegido

## 1. ¿A qué nos referimos con modo real y con modo protegido en un procesador Intel? ¿Qué particularidades tiene cada modo?

### Modo Protegido
El modo operativo nativo del procesador. Es el modo en el que se pueden usar todas las herramientas de la arquitectura. Proporciona alta flexibilidad y alto rendimiento, especialmente diseñado para multitasking.

- Trabaja por defecto en 32 bits.
- Se puede direccionar hasta 4GB de memoria.
- Ofrece una enorme cantidad de instrucciones y la posibilidad de cambiar a cualquier modo.
- Tiene 4 niveles de privilegio para los segmentos, lo que permite protegerlos al limitar el acceso según el privilegio. Las operaciones críticas del sistema operativo pueden estar protegidas en segmentos más privilegiados que los del código de usuario.

### Modo Real
Es el modo en el que inician todos los procesadores x86 después de un power-up o un reset.

- Trabaja por defecto en 16 bits.
- Se puede direccionar poco más de 1MB de memoria, que solo puede dividirse en segmentos.
- Solo puede ejecutar instrucciones de un procesador Intel 8086, con algunas extensiones para cambiar entre modos de operación.
- No hay niveles de privilegio ni protección de memoria, lo que permite que cualquier programa o tarea modifique cualquier parte de la memoria.

## 2. Importancia del Modo Protegido

El pasaje al modo protegido es necesario para usar el procesador con todo su potencial. Esto se debe a que el modo protegido proporciona protección de memoria, está diseñado para multitasking, ofrece muchos más registros y más espacio en memoria. Si tuviéramos un sistema operativo en modo real, estaríamos muy limitados.

## 3. ¿Qué es la GDT? ¿Cómo es el formato de un descriptor de segmento, bit a bit? Explicación de los campos Limit, Base, G, P, DPL, S

La GDT (Global Descriptor Table) es una tabla ubicada en la memoria principal que contiene los descriptores de segmento. Los descriptores de segmento son estructuras que proporcionan al procesador el tamaño, ubicación en memoria e información sobre el acceso y estado de la información (si está en memoria o no). Estas estructuras tienen un tamaño de 2 bytes. A continuación, se detallan algunos de sus campos:

- **Limit (segment limit field)**: Es el tamaño del segmento, representado en 20 bits. Dependiendo del campo de la granularidad (G), si G está en 0, Limit se interpreta en bytes; si G está en 1, Limit se interpreta en 4KBytes (n*4KBytes).
- **Base (Base address fields)**: Define la ubicación del byte 0 del segmento dentro de los 4 GBytes de espacio lineal, con un valor de 32 bits.
- **G (Granularity flag)**: Determina la escala del campo Limit.
- **P flag (segment-present flag)**: Indica si el segmento está en memoria (P en 1) o no (P en 0), generando una excepción (segment-not-present) si no está en memoria.
- **DPL (descriptor privilege level field)**: Indica el nivel de privilegio del segmento, de 0 a 3, siendo 0 el más privilegiado.
- **S (descriptor type flag)**: Especifica si el descriptor de segmento es para un segmento de sistema (S en 0) o para código o datos (S en 1).

## 4.La tabla de la sección 3.4.5.1 Code- and Data-Segment Descriptor Types del volumen 3 del manual del Intel nos permite completar el Type, los bits 11, 10, 9, 8. ¿Qué combinación de bits tendríamos que usar si queremos especificar un segmento para ejecución y lectura de código?

Según la tabla de la sección 3.4.5.1 "Code- and Data-Segment Descriptor Types" del volumen 3 del manual de Intel, la combinación de bits para especificar un segmento para ejecución y lectura de código sería 1010.
