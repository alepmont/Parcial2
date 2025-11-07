extends CharacterBody2D

@export var chase_speed: float = 150.0
@export var jump_velocity: float = -350.0

var player = null
var sprite: AnimatedSprite2D
var is_active: bool = true

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
