extends Control

var left_pressed = false
var right_pressed = false
var jump_pressed = false

var touch_to_action := {}
var action_touch_count := {
	"move_left": 0,
	"move_right": 0,
	"jump": 0,
}

var mouse_action := ""

func _ready():
	# Los botones se usan como UI visual; el input se procesa manualmente para soportar multitouch.
	$LeftButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$RightButton.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$JumpButton.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _input(event):
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_register_touch(touch_event.index, touch_event.position)
		else:
			_release_touch(touch_event.index)
		return

	if event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		_update_touch(drag_event.index, drag_event.position)
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			mouse_action = _get_action_at_position(mouse_event.position)
			if mouse_action != "":
				_press_action(mouse_action)
		else:
			if mouse_action != "":
				_release_action(mouse_action)
				mouse_action = ""
		return

	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var motion_event := event as InputEventMouseMotion
		var next_action := _get_action_at_position(motion_event.position)
		if next_action != mouse_action:
			if mouse_action != "":
				_release_action(mouse_action)
			mouse_action = next_action
			if mouse_action != "":
				_press_action(mouse_action)

func _register_touch(index: int, touch_pos: Vector2):
	var action := _get_action_at_position(touch_pos)
	if action == "":
		return
	touch_to_action[index] = action
	_press_action(action)

func _release_touch(index: int):
	if not touch_to_action.has(index):
		return
	var action: String = touch_to_action[index]
	touch_to_action.erase(index)
	_release_action(action)

func _update_touch(index: int, touch_pos: Vector2):
	var next_action := _get_action_at_position(touch_pos)
	var current_action := ""
	if touch_to_action.has(index):
		current_action = touch_to_action[index]

	if next_action == current_action:
		return

	if current_action != "":
		_release_action(current_action)
		touch_to_action.erase(index)

	if next_action != "":
		touch_to_action[index] = next_action
		_press_action(next_action)

func _get_action_at_position(touch_pos: Vector2) -> String:
	if $LeftButton.get_global_rect().has_point(touch_pos):
		return "move_left"
	if $RightButton.get_global_rect().has_point(touch_pos):
		return "move_right"
	if $JumpButton.get_global_rect().has_point(touch_pos):
		return "jump"
	return ""

func _press_action(action: String):
	action_touch_count[action] += 1
	if action_touch_count[action] == 1:
		Input.action_press(action)
	_sync_state_flags()

func _release_action(action: String):
	action_touch_count[action] = max(0, action_touch_count[action] - 1)
	if action_touch_count[action] == 0:
		Input.action_release(action)
	_sync_state_flags()

func _sync_state_flags():
	left_pressed = action_touch_count["move_left"] > 0
	right_pressed = action_touch_count["move_right"] > 0
	jump_pressed = action_touch_count["jump"] > 0

func _on_left_pressed():
	_press_action("move_left")

func _on_left_released():
	_release_action("move_left")

func _on_right_pressed():
	_press_action("move_right")

func _on_right_released():
	_release_action("move_right")

func _on_jump_pressed():
	_press_action("jump")

func _on_jump_released():
	_release_action("jump")
