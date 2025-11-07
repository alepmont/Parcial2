extends Area2D

enum CollectibleType { GLASSES, WATER }
@export var type: CollectibleType = CollectibleType.GLASSES
@export var health_bonus: int = 1

func _ready():
	add_to_group("collectible")
	body_entered.connect(_on_body_entered)
	
	# Configurar bonus según el tipo
	if type == CollectibleType.GLASSES:
		health_bonus = 1
	else:  # WATER
		health_bonus = 1

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Dar salud al jugador
		if body.has_method("add_health"):
			body.add_health(health_bonus)
		if body.has_method("play_sound") and body.collect_sound:
			body.play_sound(body.collect_sound)
		# Efecto visual y eliminar
		modulate = Color(2, 2, 2, 1)
		queue_free()
