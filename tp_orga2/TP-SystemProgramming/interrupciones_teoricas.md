# Preguntas Teoricas sobre Interrupciones

## 1. a) Observen que la macro IDT_ENTRY0 corresponde a cada entrada de la IDT de nivel 0 ¿A qué se refiere cada campo? ¿Qué valores toma el campo offset?

Observen que la macro `IDT_ENTRY0` corresponde a cada entrada de la IDT de nivel 0. A continuación, se describe a qué se refiere cada campo y los valores que toma el campo offset:

- **offset_31_16 y offset_15_0**: Este campo indica el offset con respecto a la dirección base del segmento de código de nivel 0 que indica dónde está la rutina relacionada a la interrupción levantada.
- **segsel**: Dirección física a la entrada en la GDT que contiene información sobre el segmento donde está la rutina asociada a la interrupción.
- **type**: Indica el tipo de descriptor. En este caso, es uno de sistema para una interrupción de 32 bits.
- **dpl**: Indica el nivel de privilegio con el que se puede acceder al segmento (en este caso, nivel 0).
- **present**: Indica si el segmento está en memoria.

## 3. Prólogo y Epílogo de las Rutinas de Interrupción

### Prólogo y Epílogo

- Si el prólogo es `pushad`, lo que hace es guardar en la pila todos los registros de propósito general, para luego poder restaurarlos al retornar de la interrupción. Esto se hace para que la tarea que levantó la interrupción no vea afectada su ejecución.
- El epílogo restaura el valor de los registros de propósito general con la instrucción `popad`. 

### Uso de `iret` vs `ret`

- La instrucción `iret` regresa el estado de la pila y al estado de la tarea antes de que fuese levantada la interrupción. Por ejemplo, restaura el `EIP` para continuar la ejecución justo donde se dejó. Dependiendo de si fue una interrupción externa o syscall, el valor es `EIP` o `EIP + 2`.

- No usamos `ret` porque `iret` restaura el registro de banderas (EFLAGS) y el segmento de código (CS), lo cual es esencial para retornar de una interrupción de manera adecuada, mientras que `ret` no hace ninguna de estas dos cosas.
