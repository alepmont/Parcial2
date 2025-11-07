extends Area2D

var dialogue_shown = false

func _ready():
	add_to_group("friend")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and not dialogue_shown:
		dialogue_shown = true
		
		# Detener a todos los policías
		var police_list = get_tree().get_nodes_in_group("police")
		for police in police_list:
			if police.has_method("stop_chasing"):
				police.stop_chasing()
		
		# Activar el final del juego
		if body.has_method("win_game"):
			body.win_game()
