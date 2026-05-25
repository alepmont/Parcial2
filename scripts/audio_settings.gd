extends Node

const SETTINGS_PATH := "user://settings.cfg"
const AUDIO_SECTION := "audio"

var music_volume := 0.8
var sfx_volume := 0.8

func _ready() -> void:
	load_settings()

func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)
	if err != OK:
		save_settings()
		return

	music_volume = clampf(float(config.get_value(AUDIO_SECTION, "music_volume", music_volume)), 0.0, 1.0)
	sfx_volume = clampf(float(config.get_value(AUDIO_SECTION, "sfx_volume", sfx_volume)), 0.0, 1.0)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value(AUDIO_SECTION, "music_volume", music_volume)
	config.set_value(AUDIO_SECTION, "sfx_volume", sfx_volume)
	config.save(SETTINGS_PATH)

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	save_settings()

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	save_settings()

func get_music_volume_db() -> float:
	return _linear_to_db(music_volume)

func get_sfx_volume_db() -> float:
	return _linear_to_db(sfx_volume)

func _linear_to_db(value: float) -> float:
	if value <= 0.0:
		return -80.0
	return linear_to_db(value)
