extends Node2D

@export var board_height: int
@export var board_length: int
@export var tile_border_size: int
#This way, we can access the Tile Scene, instanciate and control it with the board
const tile_scene = preload("res://Scenes/tile_scene.tscn")
#This will bring the body of the player, which is controlled by the board
const player_body_scene = preload("res://Scenes/player_body.tscn")
var player_body: Node2D

#Matrix with the center position of each tile
var board_position_matrix: Array

#Checks if the player is able to be selected
var player_position: Vector2
var player_on_tile: bool = false

#Checking if player is selected to move or not
var player_to_move: bool = false

func _ready() -> void:
	#Creates the board as the game loads
	board_position_generator(board_height, board_length, tile_border_size)
	tile_generator(board_height, board_length, tile_border_size, board_position_matrix)
	player_start()
	

func _process(_delta: float) -> void:
	player_selected_check()

func board_position_generator(height: int, length: int, tile_size: int) -> void:
	#Creates the matrix that has all the centers of the tiles
	var x_start: int = round(tile_size/2.0)
	var y_start: int = round(tile_size/2.0)
	
	for i in range(height):
		var position_array_creator: Array
		for j in range(length):
			position_array_creator.append(Vector2((x_start + j * tile_size),(y_start + i * tile_size)))
		board_position_matrix.append(position_array_creator)
		

func tile_generator(height: int, length: int, tile_size: int, positions: Array) -> void:
	#Creates the interectable tiles for the board
	var scaling: float = (tile_size - 2)/(2.0*10.0)
	
	for i in range(height):
		for j in range(length):
			var tile = tile_scene.instantiate()
			
			#Connects each tile's signal to the board's signal
			tile.tile_hovered.connect(_on_board_tile_hovered)
			
			add_child(tile)
			tile.position = positions[i][j]
			tile.scale *= scaling
			tile.board_position = Vector2(i, j)
	

func player_start() -> void:
	#This function puts the player's sprite on the board
	player_body = player_body_scene.instantiate()
	add_child(player_body)
	
	#Selects a random starting position for the player on the left side of the board
	var random_starting_position = randi_range(0, board_height - 1)
	
	#Gives the information about the player position to both the player sprite and player control
	player_body.board_position = Vector2(random_starting_position, 0)
	player_position = Vector2(random_starting_position, 0)
	
	#Sets initial position and the scale of the player sprite
	player_body.position = board_position_matrix[random_starting_position][0]
	player_body.scale = Vector2(0.4, 0.4)
	

func _on_board_tile_hovered(tile_position: Vector2) -> void:
	if player_position == tile_position:
		player_on_tile = true
		print("Player is in Tile ({0})".format([tile_position]))
	else:
		player_on_tile = false
		print("Player is not on this Tile!")

func player_selected_check() -> void:
	if player_on_tile and Input.is_action_just_pressed("action") and !player_to_move:
		player_to_move = true
		print(player_to_move)
	elif player_on_tile and Input.is_action_just_pressed("action") and player_to_move:
		player_to_move = false
		print(player_to_move)

func player_movement(range: int) -> void:
	pass
	
	
	
	
	
	
	
	
	
	
