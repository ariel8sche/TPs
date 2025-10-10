section .rodata

align 16

	rojo_coef  dd 0.2126, 0.2126, 0.2126, 0.2126
    verde_coef dd 0.7152, 0.7152, 0.7152, 0.7152
    azul_coef  dd 0.0722, 0.0722, 0.0722, 0.0722
	mascara_rojo:   db 0, 0x80, 0x80, 0x80, 4, 0x80, 0x80, 0x80, 8, 0x80, 0x80, 0x80, 12, 0x80, 0x80, 0x80
	mascara_verde:  db 1, 0x80, 0x80, 0x80, 5, 0x80, 0x80, 0x80, 9, 0x80, 0x80, 0x80, 13, 0x80, 0x80, 0x80
	mascara_azul:   db 2, 0x80, 0x80, 0x80, 6, 0x80, 0x80, 0x80,10, 0x80, 0x80, 0x80, 14, 0x80, 0x80, 0x80
	mascara_alpha 	db 0, 0, 0, 0xFF, 0, 0, 0, 0xFF, 0, 0, 0, 0xFF, 0, 0, 0, 0xFF
	mascara_pixel 	db 0, 0, 0, 0, 4, 4, 4, 4, 8, 8, 8, 8, 12, 12, 12, 12

section .text

; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - ej1
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Convierte una imagen dada (`src`) a escala de grises y la escribe en el
; canvas proporcionado (`dst`).
;
; Para convertir un píxel a escala de grises alcanza con realizar el siguiente
; cálculo:
; ```
; luminosidad = 0.2126 * rojo + 0.7152 * verde + 0.0722 * azul 
; ```
;
; Como los píxeles de las imágenes son RGB entonces el píxel destino será
; ```
; rojo  = luminosidad
; verde = luminosidad
; azul  = luminosidad
; alfa  = 255
; ```
;
; Parámetros:
;   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
;             canal.
;   - width:  El ancho en píxeles de `src` y `dst`.
;   - height: El alto en píxeles de `src` y `dst`.
global ej1
ej1:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits.
	;
	; RDI = r/m64 = rgba_t*  dst
	; RSI = r/m64 = rgba_t*  src
	; RDX = r/m32 = uint32_t width
	; RCX = r/m32 = uint32_t height

	imul rdx, rcx
	xor r8, r8 		

	.loop:
		cmp r8, rdx
		jae .end

		movdqu xmm0, [rsi + r8 * 4]		; leo 4 pixeles de la imagen origen
		movdqu xmm1, xmm0				; copio los bytes a xmm1 para procesar el canal verde
		movdqu xmm2, xmm0				; copio los bytes a xmm2 para procesar el canal azul

		pshufb xmm0, [mascara_rojo] 	; me quedo con el canal rojo
		pshufb xmm1, [mascara_verde]	; me quedo con el canal verde
		pshufb xmm2, [mascara_azul]		; me quedo con el canal azul

		cvtdq2ps xmm0, xmm0				; convierto los bytes a float
		cvtdq2ps xmm1, xmm1				; convierto los bytes a float
		cvtdq2ps xmm2, xmm2				; convierto los bytes a float

		mulps xmm0, [rojo_coef]			; multiplico por el coeficiente rojo
		mulps xmm1, [verde_coef]		; multiplico por el coeficiente verde
		mulps xmm2, [azul_coef]			; multiplico por el coeficiente azul

		addps xmm0, xmm1				; sumo el resultado de rojo y verde
		addps xmm0, xmm2				; sumo el resultado de rojo, verde y azul

		cvttps2dq xmm0, xmm0			; convierto el resultado a entero

		pshufb xmm0, [mascara_pixel]	; coloco el resultado de luminosidad en los 4 píxeles en cada canal

		movdqa xmm1, [mascara_alpha]	; coloco el valor de alfa en 255 en su canal respectivo

		por xmm0, xmm1					; pongo el byte alfa en 255

		movdqu [rdi + r8 * 4], xmm0		; guardo el resultado en la imagen destino

		add r8, 4						; incremento el contador de píxeles
		jmp .loop						; vuelvo al inicio del bucle

.end:
	ret								; retorno de la función


	