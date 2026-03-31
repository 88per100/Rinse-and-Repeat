extends Node2D
class_name Enemy

@export_category("Enemy Properties")
@export_subgroup("Enemy Stats")
@export var max_health: int = 100
@export var pace: int = 1
@export var agility: int = 3
@export_subgroup("Enemy Actions")
@export var enemy_sprite: Sprite2D
@export var actions: Array[String] = ["ATTACK", "HEAL"]
@export var move_directions: Array[String] = ["UP", "DOWN", "RIGHT", "LEFT"]

var board_position: Vector2i
var possible_enemy_movements: Array[Vector2i]

func enemy_available_tiles_maker(board_height: int, board_length: int, board_tiles: Dictionary) -> void:
	
	possible_enemy_movements.append(board_position)
	
	for direction in move_directions:
		match direction:
				"UP":
					for reach in range(pace + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = board_position + Vector2i(-reach, 0)
						if possible_position.x < 0:
							break
						var possible_tile = board_tiles[possible_position]
						var condition: bool = !possible_tile.object_here and !possible_tile.is_enemy_here and !possible_tile.is_player_here
						if condition:
							possible_enemy_movements.append(possible_position)
						else:
							break
						
					
				"DOWN":
					for reach in range(pace + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = board_position + Vector2i(reach, 0)
						if possible_position.x >= board_height:
							break
						var possible_tile = board_tiles[possible_position]
						var condition: bool = !possible_tile.object_here and !possible_tile.is_enemy_here and !possible_tile.is_player_here
						if condition:
							possible_enemy_movements.append(possible_position)
						else:
							break
						
					
				"LEFT":
					for reach in range(pace + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = board_position + Vector2i(0, -reach)
						if possible_position.y < 0:
							break
						var possible_tile = board_tiles[possible_position]
						var condition: bool = !possible_tile.object_here and !possible_tile.is_enemy_here and !possible_tile.is_player_here
						if condition:
							possible_enemy_movements.append(possible_position)
						else:
							break
						
					
				"RIGHT":
					for reach in range(pace + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = board_position + Vector2i(0, reach)
						if possible_position.y >= board_length:
							break
						var possible_tile = board_tiles[possible_position]
						var condition: bool = !possible_tile.object_here and !possible_tile.is_enemy_here and !possible_tile.is_player_here
						if condition:
							possible_enemy_movements.append(possible_position)
						else:
							break
	

func  enemy_action() -> void:
	print("Enemy made an action!")
