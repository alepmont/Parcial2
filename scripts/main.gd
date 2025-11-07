extends Node2D

var game_ended = false
var max_hearts = 3
var heart_containers = []
var music_player = null

# Sprites de corazones (se cargarán cuando Godot importe los PNG)
var heart_full_texture
var heart_empty_texture

func _ready():
	# Cargar texturas de corazones
	heart_full_texture = load("res://sprites/ui/heart_full.png")
	heart_empty_texture = load("res://sprites/ui/heart_empy.png")
	
	# Crear corazones en la UI
	create_hearts()
	# Inicializar UI
	update_health_ui(3)
	# Iniciar música de fondo
	play_background_music()

func play_background_music():
	music_player = AudioStreamPlayer.new()
	music_player.stream = load("res://sounds/music/level_theme.ogg")
	music_player.volume_db = -10
	music_player.autoplay = true
	add_child(music_player)
	music_player.play()
	
	# Configurar para que se repita en loop
	music_player.finished.connect(_on_music_finished)

func _on_music_finished():
	# Reiniciar la música solo si el juego no ha terminado
	if not game_ended and music_player:
		music_player.play()

func create_hearts():
	# Crear 3 corazones en la esquina superior izquierda
	for i in range(max_hearts):
		var heart = TextureRect.new()
		heart.texture = heart_full_texture
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.custom_minimum_size = Vector2(40, 40)
		heart.position = Vector2(10 + (i * 45), 10)
		
		$UI.add_child(heart)
		heart_containers.append(heart)

func update_health_ui(health):
	# Actualizar cada corazón según la vida actual
	for i in range(max_hearts):
		if i < health:
			# Corazón lleno
			heart_containers[i].texture = heart_full_texture
		else:
			# Corazón vacío
			heart_containers[i].texture = heart_empty_texture

func game_over():
	if not game_ended:
		game_ended = true
		# Detener la música de fondo
		if music_player:
			music_player.stop()
		$UI/MessageLabel.text = "GAME OVER"
		$UI/MessageLabel.visible = true
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()

func win_level():
	if not game_ended:
		game_ended = true
		# Detener la música de fondo
		if music_player:
			music_player.stop()
		# Cambiar a la escena de victoria
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://scenes/victory.tscn")
