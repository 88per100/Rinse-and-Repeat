extends Node2D
class_name Board

@onready var tile_scene: PackedScene = preload("uid://biqedlsv4qd0v")
@onready var turn_control_scene: PackedScene = preload("uid://c7aa8xuqmjbrc")

@export_subgroup("Board Dimensions")
@export var height_min: int = 3
@export var height_max: int = 8
@export_range(0.5, 1.0) var board_screen_ratio: float

#TESTING
@onready var player: PackedScene = preload("uid://bbqrjumu8yvow")
@onready var enemy_1: PackedScene = preload("uid://du7vixn5psi54")
@onready var enemy_2: PackedScene = preload("uid://bl8svrbyycwbd")
var character_list: Array[CharacterClass]
#----------------

var height: int
var length: int
var tile_size: float

var turn_control: TurnControl
var transition_range: Array[float] = [0.3, 0.4]

var logical_board: Array[Vector2i]
var positions_dictionary: Dictionary[Vector2i, Vector2]
var tile_dictionary: Dictionary[Vector2i, Tile]

var player_character: CharacterClass
var player_to_move: bool = false
signal player_movement_over()
signal player_action_over()
signal npc_movement_over()
signal npc_action_over()
signal new_turn()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_board_dimensions()
	logical_board = logical_board_creator()
	positions_dictionary = positions_dictionary_creator()
	turn_control_initializer()
	board_tile_placer()
	
	character_tester_placer()
	#After getting characters
	turn_control.turn_start(character_list)
	
	new_turn.emit()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_board_dimensions() -> void:
	height = randi_range(height_min, height_max)
	tile_size = get_viewport_rect().end.y * board_screen_ratio / height
	
	var length_array: Array[int]
	for i in range(height, height * 2):
		if (i / float(height)) >= 1.5 and (i / float(height)) < (16.0 / 9.0):
			length_array.append(i)
		else:
			continue
	
	length = length_array[randi_range(0, length_array.size() - 1)]
	

func logical_board_creator() -> Array[Vector2i]:
	var result: Array[Vector2i]
	
	for i in range(height):
		for j in range(length):
			result.append(Vector2i(i, j))
	
	return result
	

func positions_dictionary_creator() -> Dictionary[Vector2i, Vector2]:
	var result: Dictionary[Vector2i, Vector2]
	
	var center_position: Vector2 = Vector2(get_viewport_rect().end.x, get_viewport_rect().end.y) * 0.5
	
	var first_tile_position: Vector2 = center_position - Vector2(tile_size * (length - 1) * 0.5, tile_size * (height - 1) * 0.5)
	
	var current_position: Vector2 = first_tile_position
	
	for pos in logical_board:
		result[pos] = current_position + Vector2(pos.y * tile_size, pos.x * tile_size)
		
	
	return result
	

func turn_control_initializer() -> void:
	turn_control = turn_control_scene.instantiate()
	add_child(turn_control)
	turn_control.update_turn_ui()
	

func board_tile_placer() -> void:
	
	for logical_position in logical_board:
		var tile: Tile = tile_scene.instantiate()
		add_child(tile)
		
		tile_dictionary[logical_position] = tile
		
		tile.tile_logical_position = logical_position
		tile.tile_pressed.connect(_on_tile_pressed)
		
		tile.scale *= tile_size/30.0
		tile.position = positions_dictionary[logical_position]
	

#TESTING FUNCTION
func character_tester_placer() -> void:
	var player_scene = player.instantiate()
	add_child(player_scene)
	var enemy1_scene = enemy_1.instantiate()
	add_child(enemy1_scene)
	var enemy2_scene = enemy_2.instantiate()
	add_child(enemy2_scene)
	
	player_character = player_scene
	character_list.append(player_scene)
	character_list.append(enemy1_scene)
	character_list.append(enemy2_scene)
	
	for index in range(character_list.size()):
		var rand_position: Vector2i = Vector2i(index, randi_range(0, length - 1))
		
		tile_dictionary[rand_position].occupied = true
		tile_dictionary[rand_position].character_in_tile = index
		
		character_list[index].level_index = index
		character_list[index].level_start()
		
		character_list[index].board_position = rand_position
		character_list[index].position = positions_dictionary[rand_position]
		character_list[index].scale *= tile_size/200.0
	

func character_turn() -> void:
	var current_index: int = turn_control.turn_order.pop_front()
	var current_character: CharacterClass = character_list[current_index]
	
	if current_character.player_character:
		player_movement(current_character)
		await player_movement_over
		player_action(current_character)
		await player_action_over
	else:
		npc_movement(current_character)
		await npc_movement_over
		npc_action(current_character)
		await npc_action_over
	
	turn_control.turn_actions -= 1
	
	new_turn.emit()
	

func _on_new_turn() -> void:
	
	if turn_control.turn_actions == 0:
		turn_control.turn_end()
		turn_control.turn_start(character_list)
	
	character_turn()
	

func _on_tile_pressed(tile_lp: Vector2i, character_index: int, can_player_move_here: bool) -> void:
	print(character_index)
	if player_to_move:
		check_player_movement(tile_lp, can_player_move_here)
	

func player_movement(character: CharacterClass) -> void:
	character.movement_calculator(tile_dictionary, height, length)
	for tile_position in character.possible_movements:
		var tile: Tile = tile_dictionary[tile_position]
		tile.highlight(tile.movement_highlight)
		tile.player_can_move_here = true
		
	
	player_to_move = true
	
	await player_movement_over
	
	for tile_position in character.possible_movements:
		var tile: Tile = tile_dictionary[tile_position]
		tile.un_highlight()
		tile.player_can_move_here = false
		
	
	character.possible_movements.clear()
	player_to_move = false
	

func check_player_movement(tile_position: Vector2i, can_move: bool) -> void:
	if !can_move:
		print("Player can't move here!")
	else:
		update_position(player_character, player_character.board_position, tile_position)
		
		await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
		player_movement_over.emit()
		
	

func player_action(character: CharacterClass) -> void:
	print("{0} made an action!".format([character.character_name]))
	
	await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
	player_action_over.emit()
	

func npc_movement(character: CharacterClass) -> void:
	character.movement_calculator(tile_dictionary, height, length)
	var next_position_index: int = randi_range(0, character.possible_movements.size() - 1)
	var next_position: Vector2i = character.possible_movements[next_position_index]
	update_position(character, character.board_position, next_position)
	character.possible_movements.clear()
	
	await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
	npc_movement_over.emit()
	

func npc_action(character: CharacterClass) -> void:
	print("{0} made an action!".format([character.character_name]))
	
	await get_tree().create_timer(randf_range(transition_range[0], transition_range[1])).timeout
	npc_action_over.emit()
	

func update_position(character: CharacterClass, current_position: Vector2i, new_position: Vector2i) -> void:
	tile_dictionary[current_position].occupied = false
	tile_dictionary[current_position].character_in_tile = -1
	
	var movement_timer: float = randf_range(0.1, 0.5)
	var movement_tween: Tween = create_tween()
	movement_tween.tween_property(character, "position", positions_dictionary[new_position], movement_timer)
	movement_tween.set_ease(Tween.EASE_OUT)
	movement_tween.set_trans(Tween.TRANS_LINEAR)
	movement_tween.play()
	await movement_tween.finished
	movement_tween.kill()
	
	character.board_position = new_position
	tile_dictionary[new_position].occupied = true
	tile_dictionary[new_position].character_in_tile = character.level_index
	



func _on_npc_action_over() -> void:
	print("NPC Action Over!") # Replace with function body.


func _on_npc_movement_over() -> void:
	print("NPC Movement Over!") # Replace with function body.


func _on_player_action_over() -> void:
	print("Player Action Over!") # Replace with function body.


func _on_player_movement_over() -> void:
	print("Player Movement Over!") # Replace with function body.
