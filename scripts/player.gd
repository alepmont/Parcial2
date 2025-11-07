extends CharacterBody2D

# Constantes de movimiento
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

# Sistema de vida
var max_health = 3
var current_health = 3
var is_invulnerable = false
var invulnerability_time = 1.0

# Referencia al juego principal
@onready var game = get_parent()

# Sonidos
var jump_sound
var hurt_sound
var collect_sound

func _ready():
	add_to_group("player")
	
	# Cargar sonidos (verificar si existen)
	if ResourceLoader.exists("res://sounds/sfx/jump.wav"):
		jump_sound = load("res://sounds/sfx/jump.wav")
	if ResourceLoader.exists("res://sounds/sfx/hurt.wav"):
		hurt_sound = load("res://sounds/sfx/hurt.wav")
	if ResourceLoader.exists("res://sounds/sfx/collect.wav"):
		collect_sound = load("res://sounds/sfx/collect.wav")

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Manejo del salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_sound(jump_sound)
	
	# Obtener dirección de movimiento horizontal
	var direction = Input.get_axis("move_left", "move_right")
	
	# Aplicar zona muerta para evitar movimiento no deseado (importante para joysticks)
	if abs(direction) < 0.2:
		direction = 0.0
	
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		# Decelerar suavemente cuando no hay input
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	# Actualizar animaciones
	update_animation(direction)
	
	# Verificar colisiones con objetos y obstáculos
	check_collisions()

func update_animation(direction):
	if not has_node("AnimatedSprite2D"):
		return
	
	var anim_sprite = $AnimatedSprite2D
	
	# Voltear sprite según dirección
	if direction > 0:
		anim_sprite.flip_h = false
	elif direction < 0:
		anim_sprite.flip_h = true
	
	# Seleccionar animación
	if not is_on_floor():
		anim_sprite.play("jump")
	elif abs(velocity.x) > 10:
		anim_sprite.play("walk")
	else:
		anim_sprite.play("idle")

func play_sound(sound_stream):
	if sound_stream:
		var audio_player = AudioStreamPlayer.new()
		audio_player.stream = sound_stream
		add_child(audio_player)
		audio_player.play()
		audio_player.finished.connect(func(): audio_player.queue_free())

func check_collisions():
	# Verificar colisiones con áreas (objetos coleccionables, obstáculos)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider.is_in_group("collectible"):
			collect_item(collider)
		elif collider.is_in_group("obstacle") or collider.is_in_group("police"):
			if not is_invulnerable:
				take_damage()
		elif collider.is_in_group("friend"):
			win_game()

func collect_item(item):
	if item.has_method("collect"):
		var health_bonus = item.collect()
		add_health(health_bonus)
		play_sound(collect_sound)

func add_health(amount):
	current_health = min(current_health + amount, max_health)
	game.update_health_ui(current_health)

func take_damage():
	current_health -= 1
	game.update_health_ui(current_health)
	play_sound(hurt_sound)
	
	if current_health <= 0:
		die()
	else:
		# Activar invulnerabilidad temporal
		is_invulnerable = true
		# Efecto visual de parpadeo
		modulate = Color(1, 1, 1, 0.5)
		await get_tree().create_timer(invulnerability_time).timeout
		is_invulnerable = false
		modulate = Color(1, 1, 1, 1)

func die():
	game.game_over()

func win_game():
	game.win_level()
