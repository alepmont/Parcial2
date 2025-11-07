extends Control

var buttons = []
var current_button = 0

func _ready():
	# Conectar los botones
	$RestartButton.pressed.connect(_on_restart_pressed)
	$MenuButton.pressed.connect(_on_menu_pressed)
	
	# Configurar navegación con joystick
	buttons = [$RestartButton, $MenuButton]
	buttons[current_button].grab_focus()

func _input(event):
	# Navegación con teclado y joystick
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_right"):
		current_button = (current_button + 1) % buttons.size()
		buttons[current_button].grab_focus()
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left"):
		current_button = (current_button - 1 + buttons.size()) % buttons.size()
		buttons[current_button].grab_focus()
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("jump"):
		# Activar el botón con Enter, Espacio o botón A del joystick
		buttons[current_button].emit_signal("pressed")

func _on_restart_pressed():
	# Reiniciar el nivel
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_menu_pressed():
	# Volver al menú principal
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
