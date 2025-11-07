extends Control

var left_pressed = false
var right_pressed = false
var jump_pressed = false

func _ready():
	# Conectar señales de los botones
	$LeftButton.button_down.connect(_on_left_pressed)
	$LeftButton.button_up.connect(_on_left_released)
	
	$RightButton.button_down.connect(_on_right_pressed)
	$RightButton.button_up.connect(_on_right_released)
	
	$JumpButton.button_down.connect(_on_jump_pressed)
	$JumpButton.button_up.connect(_on_jump_released)

func _on_left_pressed():
	left_pressed = true
	Input.action_press("move_left")

func _on_left_released():
	left_pressed = false
	Input.action_release("move_left")

func _on_right_pressed():
	right_pressed = true
	Input.action_press("move_right")

func _on_right_released():
	right_pressed = false
	Input.action_release("move_right")

func _on_jump_pressed():
	jump_pressed = true
	Input.action_press("jump")

func _on_jump_released():
	jump_pressed = false
	Input.action_release("jump")
