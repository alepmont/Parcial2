extends Control

var buttons = []
var current_button = 0
var menu_music_player: AudioStreamPlayer
var sfx_preview_stream: AudioStream
var sfx_preview_last_time_ms := 0
var is_transitioning := false

@onready var player_name_input: LineEdit = $PlayerDataContainer/PlayerNameInput
@onready var high_scores_label: Label = $PlayerDataContainer/HighScoresLabel
@onready var settings_panel: Panel = $SettingsPanel
@onready var sound_button: Button = $VBoxContainer/sonido
@onready var music_slider: HSlider = $SettingsPanel/SettingsVBox/MusicSlider
@onready var sfx_slider: HSlider = $SettingsPanel/SettingsVBox/SfxSlider
@onready var music_value_label: Label = $SettingsPanel/SettingsVBox/MusicValueLabel
@onready var sfx_value_label: Label = $SettingsPanel/SettingsVBox/SfxValueLabel

func _ready():
	play_menu_music()
	load_sfx_preview_stream()

	# Obtener todos los botones del menú
	buttons = get_tree().get_nodes_in_group("menu_buttons")
	if buttons.size() == 0:
		# Si no hay grupo, buscar botones manualmente
		buttons = find_all_buttons(self)

	# Configurar nombre de jugador y ranking
	player_name_input.text = SaveData.player_name
	refresh_high_scores()
	setup_audio_settings_ui()
	
	# Enfocar el primer botón
	if buttons.size() > 0:
		buttons[current_button].grab_focus()

func play_menu_music() -> void:
	menu_music_player = AudioStreamPlayer.new()
	menu_music_player.stream = load("res://sounds/music/menu_theme.ogg")
	menu_music_player.volume_db = AudioSettings.get_music_volume_db()
	menu_music_player.autoplay = true
	add_child(menu_music_player)
	menu_music_player.play()

func load_sfx_preview_stream() -> void:
	if ResourceLoader.exists("res://sounds/sfx/hurt.ogg"):
		sfx_preview_stream = load("res://sounds/sfx/hurt.ogg")

func _exit_tree() -> void:
	if menu_music_player:
		menu_music_player.stop()

func find_all_buttons(node):
	var found_buttons = []
	for child in node.get_children():
		if child is Button:
			found_buttons.append(child)
		found_buttons += find_all_buttons(child)
	return found_buttons

func _input(event):
	if is_transitioning:
		return

	if settings_panel.visible:
		if event.is_action_pressed("ui_cancel") or _is_joypad_b(event):
			close_settings_panel()
			get_viewport().set_input_as_handled()
		return

	# Navegación con teclado y joystick
	if buttons.is_empty():
		return

	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		current_button = (current_button + 1) % buttons.size()
		buttons[current_button].grab_focus()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		current_button = (current_button - 1 + buttons.size()) % buttons.size()
		buttons[current_button].grab_focus()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("jump"):
		# Activar el botón con Enter, Espacio o botón A del joystick
		if buttons.size() > 0:
			buttons[current_button].emit_signal("pressed")

func _on_inicio_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	SaveData.set_player_name(player_name_input.text)
	SceneTransition.change_scene("res://scenes/main.tscn")

func _on_sonido_pressed() -> void:
	if is_transitioning:
		return
	if settings_panel.visible:
		close_settings_panel()
	else:
		open_settings_panel()

func _on_salir_pressed() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	get_tree().quit()

func _on_player_name_input_text_submitted(new_text: String) -> void:
	SaveData.set_player_name(new_text)
	player_name_input.release_focus()

func _on_player_name_input_focus_exited() -> void:
	SaveData.set_player_name(player_name_input.text)

func refresh_high_scores() -> void:
	high_scores_label.text = "Mejores puntuaciones\n" + SaveData.get_high_scores_text()

func setup_audio_settings_ui() -> void:
	close_settings_panel()
	music_slider.value = AudioSettings.music_volume
	sfx_slider.value = AudioSettings.sfx_volume
	refresh_audio_value_labels()

func _on_music_slider_value_changed(value: float) -> void:
	AudioSettings.set_music_volume(value)
	if menu_music_player:
		menu_music_player.volume_db = AudioSettings.get_music_volume_db()
	refresh_audio_value_labels()

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioSettings.set_sfx_volume(value)
	refresh_audio_value_labels()
	play_sfx_preview()

func _on_close_settings_button_pressed() -> void:
	if is_transitioning:
		return
	close_settings_panel()

func refresh_audio_value_labels() -> void:
	music_value_label.text = "Musica: %d%%" % int(round(music_slider.value * 100.0))
	sfx_value_label.text = "Sonido: %d%%" % int(round(sfx_slider.value * 100.0))

func play_sfx_preview() -> void:
	if sfx_preview_stream == null:
		return

	# Evita disparar decenas de sonidos por segundo mientras se arrastra el slider.
	var now_ms := Time.get_ticks_msec()
	if now_ms - sfx_preview_last_time_ms < 120:
		return
	sfx_preview_last_time_ms = now_ms

	var preview_player := AudioStreamPlayer.new()
	preview_player.stream = sfx_preview_stream
	preview_player.volume_db = AudioSettings.get_sfx_volume_db()
	add_child(preview_player)
	preview_player.play()
	preview_player.finished.connect(func(): preview_player.queue_free())

func open_settings_panel() -> void:
	if is_transitioning:
		return
	settings_panel.visible = true
	music_slider.grab_focus()

func close_settings_panel() -> void:
	settings_panel.visible = false
	sound_button.grab_focus()
	if not buttons.is_empty():
		current_button = buttons.find(sound_button)
		if current_button < 0:
			current_button = 0

func _is_joypad_b(event: InputEvent) -> bool:
	return event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_B
