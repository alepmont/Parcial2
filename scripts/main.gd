extends Node2D

var game_ended = false
var max_hearts = 3
var heart_containers = []
var music_player = null
var current_score = 0
var score_label: Label
var is_paused := false
const CAMERA_LEFT_LIMIT := 640.0
const CAMERA_RIGHT_LIMIT := 1920.0
const CAMERA_Y := 360.0
const LEVEL_MID_X := 1280.0
const POLICE_RESPAWN_LEFT_X := 120.0
const POLICE_RESPAWN_RIGHT_X := 2440.0
const POLICE_RESPAWN_Y := 595.0
const POLICE_SCALE := Vector2(0.24, 0.24)
const POLICE_RESPAWN_DELAY := 1.2
const POLICE_SCENE := preload("res://scenes/police.tscn")

@onready var pause_button: Button = $UI/PauseButton
@onready var pause_overlay: ColorRect = $UI/PauseOverlay
@onready var pause_menu: Panel = $UI/PauseMenu
@onready var resume_button: Button = $UI/PauseMenu/PauseMenuVBox/ResumeButton
@onready var touch_controls: Control = $UI/TouchControls
@onready var player_node: Node2D = $Player
@onready var main_camera: Camera2D = $MainCamera

# Sprites de corazones (se cargarán cuando Godot importe los PNG)
var heart_full_texture
var heart_empty_texture

func _ready():
	# Cargar texturas de corazones
	heart_full_texture = load("res://sprites/ui/heart_full.png")
	heart_empty_texture = load("res://sprites/ui/heart_empty.png")
	
	# Crear corazones en la UI
	create_hearts()
	setup_score_ui()
	# Inicializar UI
	update_health_ui(3)
	update_score_ui()
	setup_pause_ui()
	setup_police_respawn()
	# Iniciar música de fondo
	play_background_music()

func setup_police_respawn() -> void:
	for node in get_tree().get_nodes_in_group("police"):
		register_police(node)

func register_police(police: Node) -> void:
	if police == null or not police.has_signal("defeated"):
		return

	var on_defeated := Callable(self, "_on_police_defeated")
	if not police.is_connected("defeated", on_defeated):
		police.connect("defeated", on_defeated)

func _on_police_defeated(position_x: float) -> void:
	if game_ended:
		return

	var spawn_x := POLICE_RESPAWN_RIGHT_X if position_x < LEVEL_MID_X else POLICE_RESPAWN_LEFT_X
	await get_tree().create_timer(POLICE_RESPAWN_DELAY).timeout
	if game_ended:
		return
	spawn_police(spawn_x)

func spawn_police(spawn_x: float) -> void:
	var police := POLICE_SCENE.instantiate()
	if police == null:
		return

	police.position = Vector2(spawn_x, POLICE_RESPAWN_Y)
	police.scale = POLICE_SCALE
	add_child(police)
	register_police(police)

func _unhandled_input(event: InputEvent) -> void:
	if game_ended:
		return

	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if main_camera == null or player_node == null:
		return

	# La camara sigue al jugador dentro de los limites del nivel extendido.
	var cam_x := clampf(player_node.global_position.x, CAMERA_LEFT_LIMIT, CAMERA_RIGHT_LIMIT)
	main_camera.global_position = Vector2(cam_x, CAMERA_Y)

func setup_score_ui():
	score_label = $UI/ScoreLabel
	score_label.text = "Puntaje: 0"

func add_score(points: int):
	current_score += max(points, 0)
	update_score_ui()

func update_score_ui():
	if score_label:
		score_label.text = "Puntaje: %d" % current_score

func setup_pause_ui() -> void:
	pause_overlay.visible = false
	pause_menu.visible = false
	pause_overlay.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pause_button.process_mode = Node.PROCESS_MODE_ALWAYS

func toggle_pause() -> void:
	set_pause_state(not is_paused)

func set_pause_state(paused: bool) -> void:
	if game_ended:
		return

	is_paused = paused
	get_tree().paused = paused
	pause_overlay.visible = paused
	pause_menu.visible = paused
	pause_button.visible = not paused
	touch_controls.visible = not paused

	if paused:
		resume_button.grab_focus()

func _on_pause_button_pressed() -> void:
	toggle_pause()

func _on_resume_button_pressed() -> void:
	set_pause_state(false)

func _on_main_menu_button_pressed() -> void:
	set_pause_state(false)
	SceneTransition.change_scene("res://scenes/menu.tscn")

func _on_quit_button_pressed() -> void:
	set_pause_state(false)
	get_tree().quit()

func play_background_music():
	music_player = AudioStreamPlayer.new()
	music_player.stream = load("res://sounds/music/level_theme.ogg")
	music_player.volume_db = AudioSettings.get_music_volume_db()
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
		set_pause_state(false)
		# Detener la música de fondo
		if music_player:
			music_player.stop()
		SaveData.add_score(current_score)
		SceneTransition.change_scene("res://scenes/defeat.tscn")

func win_level():
	if not game_ended:
		game_ended = true
		set_pause_state(false)
		# Detener la música de fondo
		if music_player:
			music_player.stop()
		SaveData.add_score(current_score)
		# Cambiar a la escena de victoria
		await get_tree().create_timer(0.5).timeout
		SceneTransition.change_scene("res://scenes/victory.tscn")
