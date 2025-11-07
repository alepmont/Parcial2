extends Control

var buttons = []
var current_button = 0

func _ready():
	# Obtener todos los botones del menú
	buttons = get_tree().get_nodes_in_group("menu_buttons")
	if buttons.size() == 0:
		# Si no hay grupo, buscar botones manualmente
		buttons = find_all_buttons(self)
	
	# Enfocar el primer botón
	if buttons.size() > 0:
		buttons[current_button].grab_focus()

func find_all_buttons(node):
	var found_buttons = []
	for child in node.get_children():
		if child is Button:
			found_buttons.append(child)
		found_buttons += find_all_buttons(child)
	return found_buttons

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
		if buttons.size() > 0:
			buttons[current_button].emit_signal("pressed")

func _on_inicio_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_sonido_pressed() -> void:
	pass # Replace with function body.

func _on_salir_pressed() -> void:
	get_tree().quit()
