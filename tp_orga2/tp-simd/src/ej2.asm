section .rodata

align 16

mascara_rojo:   db 0, 0x80, 0x80, 0x80, 4, 0x80, 0x80, 0x80, 8, 0x80, 0x80, 0x80, 12, 0x80, 0x80, 0x80
mascara_verde:  db 1, 0x80, 0x80, 0x80, 5, 0x80, 0x80, 0x80, 9, 0x80, 0x80, 0x80, 13, 0x80, 0x80, 0x80
mascara_azul:   db 2, 0x80, 0x80, 0x80, 6, 0x80, 0x80, 0x80,10, 0x80, 0x80, 0x80, 14, 0x80, 0x80, 0x80
mascara_rgba:   db 0,4,8,12, 1,5,9,13, 2,6,10,14, 3,7,11,15

divisor:        dd 3.0, 3.0, 3.0, 3.0

const_192:      dd 192, 192, 192, 192
offset_64:      dd 64, 64, 64, 64
offset_128:     dd 128, 128, 128, 128
const_4:        dd 4, 4, 4, 4
const_384:      dd 384, 384, 384, 384
const_ff:       dd 255, 255, 255, 255

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Aplica un efecto de "mapa de calor" sobre una imagen dada (`src`). Escribe la
; imagen resultante en el canvas proporcionado (`dst`).
;
; Para calcular el mapa de calor lo primero que hay que hacer es computar la
; "temperatura" del pixel en cuestión:
; ```
; temperatura = (rojo + verde + azul) / 3
; ```
;
; Cada canal del resultado tiene la siguiente forma:
; ```
; |          ____________________
; |         /                    \
; |        /                      \        Y = intensidad
; | ______/                        \______
; |
; +---------------------------------------
;              X = temperatura
; ```
;
; Para calcular esta función se utiliza la siguiente expresión:
; ```
; f(x) = min(255, max(0, 384 - 4 * |x - 192|))
; ```
;
; Cada canal esta offseteado de distinta forma sobre el eje X, por lo que los
; píxeles resultantes son:
; ```
; temperatura  = (rojo + verde + azul) / 3
; salida.rojo  = f(temperatura)
; salida.verde = f(temperatura + 64)
; salida.azul  = f(temperatura + 128)
; salida.alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej2
ej2:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; RDI = r/m64 = rgba_t*  dst
	; RSI = r/m64 = rgba_t*  src
	; EDX = r/m32 = uint32_t width
	; ECX = r/m32 = uint32_t height
	
	push rbp
	mov rbp, rsp
	
	push r12
	push r13
	push r14
	push r15

	mov r12, rdi ; dst
	mov r13, rsi ; src
	mov r14, rdx ; width
	mov r15, rcx ; height

	imul rdx, rcx

	xor r8, r8

.loop:
	cmp r8, rdx
	jae .end

	; cargo el canal rojo de los 4 pixeles
	movdqu xmm1, [r13]

	; Canal rojo
	movdqa xmm2, xmm1
	; xmm0 = rojo | rojo | rojo | rojo
	pshufb xmm2, [mascara_rojo]

	; Canal verde
	movdqa xmm3, xmm1
	; xmm1 = verde | verde | verde | verde
	pshufb xmm3, [mascara_verde]

	; Canal azul
	movdqa xmm4, xmm1
	; xmm2 = azul | azul | azul | azul	
	pshufb xmm4, [mascara_azul]
	
	; Limpio xmm5 para almacenar la temperatura
	pxor xmm5, xmm5
	; sumo los canales rojo de los 4 pixeles
	paddw xmm5, xmm2
	; sumo los canales verde de los 4 pixeles
	paddw xmm5, xmm3
	; sumo el canal azul de los 4 pixeles
	paddw xmm5, xmm4

	; convierto de entero a float
	cvtdq2ps xmm5, xmm5

	; divido por 3
	divps xmm5, [divisor]

	cvttps2dq xmm5, xmm5

	; calculo valor del canal rojo
	movdqa xmm0, xmm5
	call aplicar_funcion
	movdqa xmm2, xmm0

	; canal verde
	movdqa xmm0, xmm5
	paddw xmm0, [offset_64]
	call aplicar_funcion
	movdqa xmm3, xmm0

	; canal azul
	movdqa xmm0, xmm5
	paddw xmm0, [offset_128]
	call aplicar_funcion
	movdqa xmm4, xmm0

	packssdw xmm2, xmm3
	packssdw xmm4, [const_ff]
	packuswb xmm2, xmm4
	pshufb xmm2, [mascara_rgba]

	; muevo xmm0 al destino
	movdqu [r12], xmm2

	add r12, 16
	add r13, 16
	add r8, 4
	jmp .loop

.end:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret


aplicar_funcion:
	; parametro de entrada: xmm0 = temperatura + offset
	; resultado en xmm0

	; resto 192 a cada temperatura,
	psubd xmm0, [const_192]

	; absoluto del valor de cada temperatura
	pabsd xmm0, xmm0
	
	; multiplico por 4 cada temperatura
	pmulld xmm0, [const_4]

	; xmm4 = 348
	movdqa xmm6, [const_384]

	; resto 384 a cada temperatura
	psubd xmm6, xmm0

	; muevo xmm4 a xmm0
	movdqa xmm0, xmm6

	; max entre 0 y temperatura
	pxor xmm7, xmm7
	pmaxsd xmm0, xmm7
	; min entre 255 y temperatura
	pminsd xmm0, [const_ff]

	ret