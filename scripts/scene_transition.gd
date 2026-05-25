extends CanvasLayer

var is_transitioning := false
var fade_time := 0.15
var overlay: ColorRect

func _ready() -> void:
	layer = 100
	overlay = ColorRect.new()
	overlay.name = "FadeOverlay"
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)

func change_scene(scene_path: String) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	await _fade_to_black()

	var err := get_tree().change_scene_to_file(scene_path)
	if err != OK:
		push_warning("No se pudo cambiar a escena: " + scene_path)

	await get_tree().process_frame
	await _fade_from_black()
	is_transitioning = false

func _fade_to_black() -> void:
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 1.0, fade_time)
	await tween.finished

func _fade_from_black() -> void:
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 0.0, fade_time)
	await tween.finished
