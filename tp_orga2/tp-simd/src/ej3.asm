section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 3A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3a
global EJERCICIO_3A_HECHO
EJERCICIO_3A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dada una imagen origen escribe en el destino `scale * px + offset` por cada
; píxel en la imagen.
;
; Parámetros:
;   - dst_depth: La imagen destino (mapa de profundidad). Está en escala de
;                grises a 32 bits con signo por canal.
;   - src_depth: La imagen origen (mapa de profundidad). Está en escala de
;                grises a 8 bits sin signo por canal.
;   - scale:     El factor de escala. Es un entero con signo de 32 bits.
;                Multiplica a cada pixel de la entrada.
;   - offset:    El factor de corrimiento. Es un entero con signo de 32 bits.
;                Se suma a todos los píxeles luego de escalarlos.
;   - width:     El ancho en píxeles de `src_depth` y `dst_depth`.
;   - height:    El alto en píxeles de `src_depth` y `dst_depth`.
global ej3a
ej3a:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi = int32_t* dst_depth
	; rsi = uint8_t* src_depth
	; edx = int32_t  scale
	; ecx = int32_t  offset
	; r8d = int      width
	; r9d = int      height

	push rbp
	mov rbp, rsp
	
	xor r10, r10
	imul r8, r9

.loop:
	cmp r10, r8
	jae .end

	pmovzxbd xmm0, [rsi]

	; revisar tema de offset y scale negativos
	movd xmm1, edx
	pshufd xmm1, xmm1, 0x00

	pmulld xmm0, xmm1

	movd xmm2, ecx
	pshufd xmm2, xmm2, 0x00

	paddd xmm0, xmm2

	movdqu [rdi], xmm0

	add rdi, 16
	add rsi, 4
	add r10, 4

	jmp .loop

.end:
	pop rbp
	ret

; Marca el ejercicio 3B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej3b
global EJERCICIO_3B_HECHO
EJERCICIO_3B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Dadas dos imágenes de origen (`a` y `b`) en conjunto con sus mapas de
; profundidad escribe en el destino el pixel de menor profundidad por cada
; píxel de la imagen. En caso de empate se escribe el píxel de `b`.
;
; Parámetros:
;   - dst:     La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - a:       La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_a: El mapa de profundidad de A. Está en escala de grises a 32 bits
;              con signo por canal.
;   - b:       La imagen origen B. Está a color (RGBA) en 8 bits sin signo por
;              canal.
;   - depth_b: El mapa de profundidad de B. Está en escala de grises a 32 bits
;              con signo por canal.
;   - width:  El ancho en píxeles de todas las imágenes parámetro.
;   - height: El alto en píxeles de todas las imágenes parámetro.
global ej3b
ej3b:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; rdi = rgba_t*  dst
	; rsi = rgba_t*  a
	; rdx = int32_t* depth_a
	; rcx = rgba_t*  b
	; r8 = int32_t* depth_b
	; r9d = int      width
	; r10d = int      height
	push rbp
	mov rbp, rsp
	mov r10d, [rbp + 16]

	xor r11, r11

	imul r9d, r10d
.loop:
	cmp r11, r9
	jae .end
 
	movdqu xmm0, [rdx] 	; depth_a
	movdqu xmm1, [r8]	; depth_b

	pcmpgtd xmm1, xmm0 ; ahora xmm0 es una mascara con los valores de depth_a

	movdqu xmm3, [rsi] ; a
	pand xmm3, xmm1
	
	; xmm4 tiene los valores de b donde depth_b es menor que depth_a

	pcmpeqd xmm5, xmm5 ; todos los bits en 1
	pxor xmm5, xmm1 ; mascara invertida donde depth_a es menor que depth_b
	movdqu xmm4, [rcx] ; b
	pand xmm4, xmm5 ; ahora xmm0 tiene los valores de b donde depth_b es menor que depth_a

	; xmm3 tiene los valores de a donde depth_a es menor que depth_b

	por xmm3, xmm4 ; ahora xmm0 tiene los valores de a o b dependiendo de la profundidad

	movdqu [rdi], xmm3 ; guardo el resultado en dst

	add r11, 4
	add rdx, 16
	add r8, 16
	add rsi, 16
	add rdi, 16
	add rcx, 16

	jmp .loop

.end:
	pop rbp
	ret
