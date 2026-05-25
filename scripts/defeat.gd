extends Control

var buttons = []
var current_button = 0
var music_player: AudioStreamPlayer
var is_transitioning := false

@onready var player_name_label: Label = $PlayerDataContainer/PlayerNameLabel
@onready var score_label: Label = $PlayerDataContainer/ScoreLabel
@onready var best_scores_label: Label = $PlayerDataContainer/BestScoresLabel

func _ready():
	play_defeat_audio()

	$RestartButton.pressed.connect(_on_restart_pressed)
	$MenuButton.pressed.connect(_on_menu_pressed)

	player_name_label.text = "Jugador: %s" % SaveData.player_name
	score_label.text = "Puntaje: %d" % SaveData.last_score
	best_scores_label.text = "Mejores puntuaciones\n" + SaveData.get_high_scores_text()

	buttons = [$RestartButton, $MenuButton]
	if not buttons.is_empty():
		buttons[current_button].grab_focus()

func _exit_tree() -> void:
	if music_player:
		music_player.stop()

func _input(event):
	if is_transitioning:
		return

	if buttons.is_empty():
		return

	if event.is_action_pressed("ui_cancel") or _is_joypad_b(event):
		_on_menu_pressed()
		return

	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		current_button = (current_button + 1) % buttons.size()
		buttons[current_button].grab_focus()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		current_button = (current_button - 1 + buttons.size()) % buttons.size()
		buttons[current_button].grab_focus()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("jump"):
		buttons[current_button].emit_signal("pressed")

func _on_restart_pressed():
	if is_transitioning:
		return
	is_transitioning = true
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_menu_pressed():
	if is_transitioning:
		return
	is_transitioning = true
	SceneTransition.change_scene("res://scenes/menu.tscn")

func play_defeat_audio() -> void:
	play_defeat_music()
	play_defeat_sfx()

func play_defeat_music() -> void:
	var music_path := ""
	for candidate in ["res://sounds/music/defeat_theme.ogg", "res://sounds/music/menu_theme.ogg"]:
		if ResourceLoader.exists(candidate):
			music_path = candidate
			break

	if music_path.is_empty():
		return

	music_player = AudioStreamPlayer.new()
	music_player.stream = load(music_path)
	music_player.volume_db = AudioSettings.get_music_volume_db()
	music_player.autoplay = true
	add_child(music_player)
	music_player.play()

func play_defeat_sfx() -> void:
	if not ResourceLoader.exists("res://sounds/sfx/hurt.ogg"):
		return

	var sfx_player := AudioStreamPlayer.new()
	sfx_player.stream = load("res://sounds/sfx/hurt.ogg")
	sfx_player.volume_db = AudioSettings.get_sfx_volume_db()
	add_child(sfx_player)
	sfx_player.play()
	sfx_player.finished.connect(func(): sfx_player.queue_free())

func _is_joypad_b(event: InputEvent) -> bool:
	return event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B
