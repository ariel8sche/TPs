#include <stdlib.h>

#include "ej1.h"

/**
 * Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - ej1
 */
bool EJERCICIO_2_HECHO = true;


/**
 * Aplica un efecto de "mapa de calor" sobre una imagen dada (`src`). Escribe
 * la imagen resultante en el canvas proporcionado (`dst`).
 *
 * Para calcular el mapa de calor lo primero que hay que hacer es computar la
 * "temperatura" del pixel en cuestión:
 * ```
 * temperatura = (rojo + verde + azul) / 3
 * ```
 *
 * Cada canal del resultado tiene la siguiente forma:
 * ```
 * |          ____________________
 * |         /                    \
 * |        /                      \        Y = intensidad
 * | ______/                        \______
 * |
 * +---------------------------------------
 *              X = temperatura
 * ```
 *
 * Para calcular esta función se utiliza la siguiente expresión:
 * ```
 * f(x) = min(255, max(0, 384 - 4 * |x - 192|))
 * ```
 *
 * Cada canal esta offseteado de distinta forma sobre el eje X, por lo que los
 * píxeles resultantes son:
 * ```
 * temperatura  = (rojo + verde + azul) / 3
 * salida.rojo  = f(temperatura)
 * salida.verde = f(temperatura + 64)
 * salida.azul  = f(temperatura + 128)
 * salida.alfa  = 255
 * ```
 *
 * Parámetros:
 *   - dst:    La imagen destino. Está a color (RGBA) en 8 bits sin signo por
 *             canal.
 *   - src:    La imagen origen A. Está a color (RGBA) en 8 bits sin signo por
 *             canal.
 *   - width:  El ancho en píxeles de `src` y `dst`.
 *   - height: El alto en píxeles de `src` y `dst`.
 */

uint8_t f(double x) {
    int delta = (int)x - 192;
    int value = 384 - 4 * abs(delta);
    if (value > 255) value = 255;
    if (value < 0) value = 0;
    return (uint8_t)value;
}

void ej2(
	rgba_t* dst,
	rgba_t* src,
	uint32_t width, uint32_t height
) {
	for (uint32_t i = 0;i < width * height; i++){
		uint8_t r = src[i].r;
		uint8_t g = src[i].g;
		uint8_t b = src[i].b;

		double temperatura = (double)((r + g + b) / 3.0);

		dst[i].r = f(temperatura);
		dst[i].g = f(temperatura + 64);
		dst[i].b = f(temperatura + 128);
		dst[i].a = 255;
	}
}
