# Script auxiliar para validar y cargar sprites
# Este script te ayuda a verificar qué sprites faltan y cuáles están listos

extends Node

# Rutas de sprites esperados
const SPRITE_PATHS = {
	"player_idle": "res://sprites/player/idle.png",
	"player_walk_1": "res://sprites/player/walk_1.png",
	"player_walk_2": "res://sprites/player/walk_2.png",
	"player_walk_3": "res://sprites/player/walk_3.png",
	"player_jump": "res://sprites/player/jump.png",
	"player_hurt": "res://sprites/player/hurt.png",
	"glasses": "res://sprites/collectibles/glasses.png",
	"water_bottle": "res://sprites/collectibles/water_bottle.png",
	"fence": "res://sprites/obstacles/fence.png",
	"police_walk_1": "res://sprites/enemies/police/police_walk_1.png",
	"police_walk_2": "res://sprites/enemies/police/police_walk_2.png",
	"friend": "res://sprites/npc/friend.png",
	"platform": "res://sprites/environment/platform.png",
	"ground": "res://sprites/environment/ground.png",
	"background": "res://sprites/background/concert_path.png"
}

func check_sprites():
	print("\n=== VERIFICACIÓN DE SPRITES ===\n")
	
	var found = 0
	var missing = 0
	
	for sprite_name in SPRITE_PATHS:
		var path = SPRITE_PATHS[sprite_name]
		if ResourceLoader.exists(path):
			print("✓ ", sprite_name, " - ENCONTRADO")
			found += 1
		else:
			print("✗ ", sprite_name, " - FALTA")
			missing += 1
	
	print("\n=== RESUMEN ===")
	print("Sprites encontrados: ", found, "/", SPRITE_PATHS.size())
	print("Sprites faltantes: ", missing, "/", SPRITE_PATHS.size())
	
	if missing == 0:
		print("\n¡Todos los sprites están listos! 🎉")
	else:
		print("\nRevisa SPRITES_GUIDE.md para más información sobre sprites faltantes.")

# Llamar esta función desde cualquier script para verificar sprites
# Ejemplo: get_node("/root/SpriteChecker").check_sprites()
