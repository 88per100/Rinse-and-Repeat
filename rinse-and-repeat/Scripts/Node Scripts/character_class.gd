extends Node2D
class_name CharacterClass

@export_subgroup("Sprites & U. I.")
@export var character_name: String
@export var character_sprite: AnimatedSprite2D
@export var player_character: bool = false
@export var health_bar: ProgressBar
@export var health_colors: Array[Color] = [Color(0.0, 0.592, 0.212, 1.0), Color(0.714, 0.4, 0.063, 1.0), Color(0.6, 0.125, 0.141, 1.0)]
@export var bleed_icon: Sprite2D
@export_subgroup("Stats")
@export var base_max_health: int
@export var base_strength: int
@export var base_resistance: int
@export var base_sharpness: int
@export var base_agility: int
@export var move_range: int
@export_subgroup("Movement Options")
@export_enum("4_Directions:4", "8_Directions:8") var movement_directions: int: 
	set(value):
		if value != 4 and value != 8: movement_directions = 4
		else: movement_directions = value
@export var obstacle_jumper: bool = false
@export_subgroup("Skills")
@export var skills: Array[Skill]

enum stats {HEALTH, STRENGTH, RESISTANCE, SHARPNESS, AGILITY, MOVE_RANGE}

var current_health: int
var current_strength: int
var current_resistance: int
var current_sharpness: int
var current_agility: int
var current_move_range: int

var board_position: Vector2i
var level_index: int
var possible_movements: Array[Vector2i]

func _process(_delta: float) -> void:
	update_health_bar_color()
	

func level_start(hp: int = base_max_health) -> void:
	health_bar.max_value = base_max_health
	
	update_health(hp)
	current_strength = base_strength
	current_resistance = base_resistance
	current_sharpness = base_sharpness
	current_agility = base_agility
	current_move_range = move_range
	

func update_health(updated_health: int) -> void:
	health_tween(updated_health)
	current_health = updated_health
	

func update_health_bar_color() -> void:
	if health_bar.ratio >= 0.5:
		health_bar.modulate = health_colors[0]
	elif health_bar.ratio >= 0.25:
		health_bar.modulate = health_colors[1]
	else:
		health_bar.modulate = health_colors[2]
	

func health_tween(target_health: int) -> void:
	var tween = create_tween()
	tween.tween_property(health_bar, "value", target_health, 0.1)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.play()
	await tween.finished
	tween.kill()
	

func take_damage(amount: int) -> void:
	var possible_health = current_health - amount
	if possible_health < 0:
		possible_health = 0
	update_health(amount)
	

func gain_health(amount: int) -> void:
	var possible_health = current_health + amount
	if possible_health > base_max_health:
		possible_health = base_max_health
	update_health(possible_health)
	

func suffer_debuff(debuff_ratio: float, debuff_stat: stats, _duration: int) -> void:
	match debuff_stat:
		stats.HEALTH:
			print("Not possible to debuff Health!")
		stats.STRENGTH:
			current_strength = floori(current_strength * (1 - debuff_ratio))
		stats.RESISTANCE:
			current_resistance = floori(current_resistance * (1 - debuff_ratio))
		stats.SHARPNESS:
			current_sharpness = floori(current_sharpness * (1 - debuff_ratio))
		stats.AGILITY:
			current_agility = floori(current_agility * (1 - debuff_ratio))
		stats.MOVE_RANGE:
			current_move_range = floori(current_move_range * (1 - debuff_ratio))
	

func apply_buff(buff_ratio: float, buff_stat: stats, _duration: int) -> void:
	match buff_stat:
		stats.HEALTH:
			print("Not possible to buff Health!")
		stats.STRENGTH:
			current_strength = floori(current_strength * (1 + buff_ratio))
		stats.RESISTANCE:
			current_resistance = floori(current_resistance * (1 + buff_ratio))
		stats.SHARPNESS:
			current_sharpness = floori(current_sharpness * (1 + buff_ratio))
		stats.AGILITY:
			current_agility = floori(current_agility * (1 + buff_ratio))
		stats.MOVE_RANGE:
			current_move_range = floori(current_move_range * (1 + buff_ratio))
	

func bleed_effect(_strength: int, _duration: int) -> void:
	print("{0} is bleeding out!".format([character_name]))
	

func movement_calculator(tiles: Dictionary[Vector2i, Tile], height: int, length: int) -> void:
	
	possible_movements.append(board_position)
	
	var obstacle_in_path: Array[bool]
	for k in movement_directions:
		obstacle_in_path.append(false)
	
	for i in range(1, move_range + 1):
		var directions: Array[Vector2i] = [Vector2i(0, i), Vector2i(0, -i), Vector2i(i, 0), Vector2i(-i, 0)]
		var l = i - 1
		if movement_directions == 8 and l > 0:
			directions.append(Vector2i(l, l))
			directions.append(Vector2i(-l, -l))
			directions.append(Vector2i(l, -l))
			directions.append(Vector2i(-l, l))
		
		for j in range(directions.size()):
			var possible_movement: Vector2i = board_position + directions[j]
			
			if (possible_movement.x < 0 or possible_movement.y < 0 or possible_movement.x >= height or possible_movement.y >= length):
				continue
			
			var is_tile_occupied: bool = tiles[possible_movement].occupied
			
			if is_tile_occupied:
				obstacle_in_path[j] = true
				continue
			elif obstacle_in_path[j] and !obstacle_jumper:
				continue
			else:
				possible_movements.append(possible_movement)
	
