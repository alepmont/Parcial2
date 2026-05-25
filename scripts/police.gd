extends CharacterBody2D

signal defeated(position_x: float)

@export var chase_speed: float = 150.0
@export var jump_velocity: float = -350.0
const DEFAULT_COLLISION_LAYER := 8
const DEFAULT_COLLISION_MASK := 1

var player = null
var sprite: AnimatedSprite2D
var is_active: bool = true
var is_defeated: bool = false
var is_stunned: bool = false

func _ready():
	add_to_group("police")
	sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Buscar al jugador si no lo tenemos
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
	
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Solo perseguir si está activo
	if is_active and player != null:
		chase_player()
	else:
		velocity.x = 0
	
	move_and_slide()

func stop_chasing():
	is_active = false
	velocity.x = 0

func stun_and_phase(duration: float, knockback_dir: float = 0.0) -> void:
	if is_defeated or is_stunned:
		return

	is_stunned = true
	is_active = false
	# Solo quitamos su capa para que el jugador lo atraviese, pero mantiene máscara
	# para seguir colisionando con suelo y paredes y no caer del nivel.
	collision_layer = 0
	collision_mask = DEFAULT_COLLISION_MASK
	if knockback_dir != 0.0:
		velocity.x = knockback_dir * 120.0
	await get_tree().create_timer(max(duration, 0.1)).timeout

	if is_defeated:
		return

	collision_layer = DEFAULT_COLLISION_LAYER
	collision_mask = DEFAULT_COLLISION_MASK
	is_active = true
	is_stunned = false

func defeat() -> void:
	if is_defeated:
		return

	is_defeated = true
	defeated.emit(global_position.x)
	is_active = false
	is_stunned = false
	collision_layer = 0
	collision_mask = 0
	visible = false
	call_deferred("queue_free")

func chase_player():
	# Perseguir al jugador
	var direction_to_player = sign(player.global_position.x - global_position.x)
	velocity.x = direction_to_player * chase_speed
	
	# Voltear solo el sprite (invertido)
	if direction_to_player > 0:
		sprite.flip_h = true   # Mirando a la derecha
	elif direction_to_player < 0:
		sprite.flip_h = false  # Mirando a la izquierda
	
	# Detectar si hay una pared u obstáculo delante y el jugador está arriba
	if is_on_floor() and is_on_wall():
		var vertical_distance = player.global_position.y - global_position.y
		# Solo saltar si el jugador está arriba (en una plataforma)
		if vertical_distance < -30:
			velocity.y = jump_velocity
