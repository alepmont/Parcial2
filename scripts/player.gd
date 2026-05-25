extends CharacterBody2D

# Constantes de movimiento
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const POLICE_LAYER_NUMBER = 4
const DAMAGE_KNOCKBACK_X = 260.0
const DAMAGE_KNOCKBACK_Y = -120.0
const STOMP_BOUNCE_VELOCITY = -280.0
const STOMP_MIN_NORMAL_Y = -0.7
const POLICE_STOMP_SCORE = 200
const POLICE_ESCAPE_RADIUS = 260.0

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
	if ResourceLoader.exists("res://sounds/sfx/hurt.ogg"):
		hurt_sound = load("res://sounds/sfx/hurt.ogg")
	if ResourceLoader.exists("res://sounds/sfx/collect.wav"):
		collect_sound = load("res://sounds/sfx/collect.wav")

	# Asegura que el jugador detecte al policia (capa 4).
	set_collision_mask_value(POLICE_LAYER_NUMBER, true)

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
		audio_player.volume_db = AudioSettings.get_sfx_volume_db()
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
		elif collider.is_in_group("police"):
			if can_stomp_police(collision, collider):
				stomp_police(collider)
			elif not is_invulnerable:
				take_damage(collider)
		elif collider.is_in_group("obstacle"):
			if not is_invulnerable:
				take_damage(collider)
		elif collider.is_in_group("friend"):
			win_game()

func can_stomp_police(collision: KinematicCollision2D, police: Object) -> bool:
	if not (police is Node2D):
		return false

	# Solo cuenta como pisoton cuando el contacto llega desde arriba.
	if collision.get_normal().y > STOMP_MIN_NORMAL_Y:
		return false

	return global_position.y < (police as Node2D).global_position.y - 8.0

func stomp_police(police: Object) -> void:
	var score_pos := global_position
	if police is Node2D:
		score_pos = (police as Node2D).global_position + Vector2(0, -28)

	if police.has_method("defeat"):
		police.defeat()
	add_score(POLICE_STOMP_SCORE)
	show_floating_points(POLICE_STOMP_SCORE, score_pos)

	velocity.y = STOMP_BOUNCE_VELOCITY

func show_floating_points(points: int, world_pos: Vector2) -> void:
	if game == null:
		return

	var points_label := Label.new()
	points_label.text = "+%d" % points
	points_label.z_index = 50
	points_label.position = world_pos
	points_label.modulate = Color(1.0, 0.95, 0.2, 1.0)
	points_label.add_theme_font_size_override("font_size", 28)
	game.add_child(points_label)

	var tween := points_label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(points_label, "position:y", points_label.position.y - 50.0, 0.45)
	tween.tween_property(points_label, "modulate:a", 0.0, 0.45)
	tween.finished.connect(func(): points_label.queue_free())

func collect_item(item):
	if item.has_method("collect"):
		var health_bonus = item.collect()
		add_health(health_bonus)
		play_sound(collect_sound)

func add_health(amount):
	current_health = min(current_health + amount, max_health)
	game.update_health_ui(current_health)

func add_score(points):
	if game and game.has_method("add_score"):
		game.add_score(points)

func take_damage(damage_source = null):
	current_health -= 1
	game.update_health_ui(current_health)
	play_sound(hurt_sound)
	apply_damage_knockback(damage_source)
	handle_police_trap_escape(damage_source)
	phase_nearby_police()
	
	if current_health <= 0:
		die()
	else:
		# Activar invulnerabilidad temporal
		is_invulnerable = true
		# Durante la invulnerabilidad, el jugador puede atravesar al policia.
		set_collision_mask_value(POLICE_LAYER_NUMBER, false)
		# Efecto visual de parpadeo
		modulate = Color(1, 1, 1, 0.5)
		await get_tree().create_timer(invulnerability_time).timeout
		set_collision_mask_value(POLICE_LAYER_NUMBER, true)
		is_invulnerable = false
		modulate = Color(1, 1, 1, 1)

func apply_damage_knockback(damage_source = null) -> void:
	var direction := 1.0

	if damage_source is Node2D:
		direction = sign(global_position.x - damage_source.global_position.x)
		if direction == 0.0:
			direction = -sign(velocity.x)
	else:
		direction = -sign(velocity.x)

	if direction == 0.0:
		direction = 1.0

	velocity.x = direction * DAMAGE_KNOCKBACK_X
	velocity.y = min(velocity.y, DAMAGE_KNOCKBACK_Y)

func handle_police_trap_escape(damage_source = null) -> void:
	if damage_source == null or not damage_source.is_in_group("police"):
		return

	if damage_source.has_method("stun_and_phase"):
		var police_pos_x: float = (damage_source as Node2D).global_position.x
		var police_push_dir: float = sign(police_pos_x - global_position.x)
		damage_source.stun_and_phase(invulnerability_time, police_push_dir)

func phase_nearby_police() -> void:
	for police in get_tree().get_nodes_in_group("police"):
		if police == null or not (police is Node2D):
			continue

		if police.global_position.distance_to(global_position) > POLICE_ESCAPE_RADIUS:
			continue

		if police.has_method("stun_and_phase"):
			var police_pos_x: float = (police as Node2D).global_position.x
			var push_dir: float = sign(police_pos_x - global_position.x)
			police.stun_and_phase(invulnerability_time, push_dir)

func die():
	game.game_over()

func win_game():
	game.win_level()
