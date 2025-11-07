# Gig in the Sky - Platformer

## Descripción del Proyecto

**Gig in the Sky** es un videojuego de plataformas 2D al estilo Mario Bros desarrollado en Godot 4.4.1.

### Historia
El jugador controla a un personaje que se dirige a un recital donde debe encontrar a sus amigos perdidos entre la multitud. En el camino, deberá superar obstáculos, evitar policías, y recolectar objetos que lo ayudarán a completar su misión.

### Objetivo
Llegar al final del nivel donde tu amigo te espera para entrar juntos al recital, mientras recolectas objetos útiles y evitas obstáculos que te harán perder vida.

## Controles

### Teclado
- **A / Flecha Izquierda**: Mover a la izquierda
- **D / Flecha Derecha**: Mover a la derecha
- **W / Flecha Arriba / Espacio**: Saltar
- **E**: Interactuar (futuras versiones)

### Joystick/Gamepad
- **Stick Izquierdo / D-Pad**: Movimiento horizontal
- **Botón A (Xbox) / X (PlayStation)**: Saltar
- **Botón B (Xbox) / Círculo (PlayStation)**: Interactuar

## Mecánicas del Juego

### Sistema de Vida
- El jugador comienza con **3 puntos de vida**
- Al colisionar con obstáculos o policías, pierde 1 punto de vida
- El jugador tiene invulnerabilidad temporal después de recibir daño (parpadea)
- Si la vida llega a 0, es Game Over

### Objetos Coleccionables
- **Lentes** (azul claro): Aumentan 1 punto de vida
- **Botella de agua** (azul): Aumenta 1 punto de vida
- Los objetos brillan al ser recolectados

### Obstáculos
- **Vallas**: Obstáculos estáticos que debes saltar
- **Policías**: Se mueven en patrulla horizontal, debes evitarlos

### Final del Nivel
- Encuentra a tu **amigo** (representado en verde) al final del nivel
- Al encontrarlo, ingresan juntos al recital y ganas el nivel

## Características Implementadas

- ✅ Física de plataformas con gravedad
- ✅ Movimiento horizontal y salto del jugador
- ✅ Sistema de vida con contador
- ✅ Objetos coleccionables (lentes y agua)
- ✅ Obstáculos estáticos (vallas)
- ✅ Enemigos con patrulla (policías)
- ✅ Colisiones y daño
- ✅ Invulnerabilidad temporal con efecto visual
- ✅ Sistema de victoria al encontrar al amigo
- ✅ UI para mostrar vida y mensajes
- ✅ Plataformas y nivel básico


## Guía de Estilo Visual

- **Colores predominantes**: Negros, violetas, luces de neón (verde, azul)
- **Tipografía**: Estilo arcade/neón
- **Estética**: Pixel art o cartoon 2D
- **Resolución**: 1280x720

## Cómo Jugar

1. Abre Godot Engine 4.2 o superior
2. Importa el proyecto seleccionando el archivo `project.godot`
3. Presiona F5 o haz clic en "Play" para iniciar el juego
4. ¡Encuentra a tu amigo y entra al recital!

## Estructura del Proyecto

```
juego/
├── project.godot
├── scenes/
│   ├── main.tscn          # Escena principal del nivel
│   └── player.tscn        # Escena del jugador
├── scripts/
│   ├── main.gd            # Lógica principal del juego
│   ├── player.gd          # Movimiento y física del jugador
│   ├── collectible.gd     # Objetos coleccionables
│   ├── obstacle.gd        # Vallas estáticas
│   ├── police.gd          # Enemigos con patrulla
│   └── friend.gd          # NPC amigo (final del nivel)
├── assets/
├── sprites/
└── sounds/
```

## Historias de Usuario Implementadas

1. ✅ Como jugador, quiero controlar a un personaje que se dirige a un recital
2. ⏳ Como jugador, quiero que los NPCs reaccionen cuando interactúe con ellos
3. ✅ Como jugador, quiero recoger objetos que me ayuden a avanzar
4. ✅ Como jugador, quiero ver un mensaje de finalización al encontrar a mi amigo

## Tecnologías

- **Engine**: Godot 4.4.1
- **Lenguaje**: GDScript
- **Plataforma**: PC (multiplataforma)

---

**Versión**: 1.0 (Prototipo)  
**Desarrollado para**: Proyecto de Arquitectura y Diseño de Interfaces
