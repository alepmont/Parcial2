# Gig in the Sky - Platformer

## Descripción

Gig in the Sky es un juego de plataformas 2D desarrollado con Godot 4.
Controlas a un personaje que busca llegar al concierto y reunirse con su amigo, superando obstáculos, policías y plataformas durante el recorrido.

## Objetivo del juego

- Avanzar hasta encontrar al amigo al final del nivel.
- Mantener la vida evitando daños.
- Sumar puntaje recolectando objetos y derrotando policías al saltarles encima.

## Estado actual del proyecto

Esta versión ya incluye:

- Menú principal con nombre de jugador, ranking y configuración de audio.
- Persistencia de datos (nombre, ranking y volumen) entre sesiones.
- Nivel extendido horizontalmente con cámara que sigue al jugador.
- Pantallas de victoria y derrota.
- Sistema de pausa en partida.

## Controles

### Teclado

- A o Flecha izquierda: mover a la izquierda.
- D o Flecha derecha: mover a la derecha.
- W, Flecha arriba o Espacio: saltar.
- Esc: pausar o reanudar.

### Gamepad

- Stick izquierdo o D-Pad: movimiento horizontal.
- Botón A: saltar.
- Botón B: acciones de retroceso en menús.

### Móvil

- Botones táctiles en pantalla para izquierda, derecha y salto.
- Botón de pausa en HUD.

## Mecánicas implementadas

### Vida y daño

- Vida inicial: 3 corazones.
- Al chocar con obstáculos o policías: pierde 1 vida.
- Invulnerabilidad temporal tras daño.
- Efecto de parpadeo durante invulnerabilidad.


### Policías

- Persiguen al jugador y pueden saltar en ciertas condiciones.
- Si el jugador les cae desde arriba (pisotón), el policía se elimina.
- Al eliminar un policía, reaparece otro en el extremo opuesto tras un breve delay.

### Puntaje

- Los coleccionables suman puntaje.
- Pisar un policía da puntaje extra.
- Se muestra feedback visual flotante del puntaje por pisotón.

### Coleccionables

- Lentes.
- Botella de agua.
- Ubicados en el piso/plataformas del nivel .

## UI y flujo de escenas

- Menú principal:
	- Iniciar partida.
	- Configurar audio (música y efectos).
	- Ver mejores puntuaciones.
	- Guardar nombre de jugador.
- Pausa en juego:
	- Volver.
	- Menú principal.
	- Salir.
- Pantalla de victoria y derrota:
	- Muestran nombre, puntaje y ranking.
	- Botones para reintentar o volver al menú.

## Persistencia

- Datos de partida: user://savegame.json
	- Nombre de jugador.
	- Ranking de mejores puntajes.
- Configuración de audio: user://settings.cfg
	- Volumen de música.
	- Volumen de efectos.

## Audio

- Música de menú y nivel con volumen configurable.
- Efectos de daño/salto/recolección según disponibilidad de recursos.
- Previsualización de SFX al mover slider de efectos.

## Estructura principal del proyecto

```text
juego/
├── project.godot
├── scenes/
│   ├── menu.tscn
│   ├── main.tscn
│   ├── player.tscn
│   ├── police.tscn
│   ├── victory.tscn
│   └── defeat.tscn
├── scripts/
│   ├── menu.gd
│   ├── main.gd
│   ├── player.gd
│   ├── police.gd
│   ├── collectible.gd
│   ├── defeat.gd
│   ├── victory.gd
│   ├── save_data.gd
│   ├── audio_settings.gd
│   └── scene_transition.gd
├── sprites/
├── sounds/
└── assets/
```

## Ejecución

1. Abrir el proyecto en Godot 4.4.x.
2. Cargar project.godot.
3. Ejecutar con F5.

## Tecnologías

- Engine: Godot 4.4.x
- Lenguaje: GDScript

---

Versión del proyecto: Prototipo jugable avanzado
