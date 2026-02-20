extends Node2D

@export var board_height: int
@export var board_length: int
@export var tile_border_size: int
#This way, we can access the Tile Scene, instanciate and control it with the board
@export var tile_scene: PackedScene
#Matrix for the board and game
var board_matrix: Array
#Matrix with the center position of each tile
var board_position_matrix: Array

func _ready() -> void:
	#Creates the board as the game loads
	board_grid_generator(board_height, board_length)
	board_position_generator(board_height, board_length, tile_border_size)
	tile_generator(board_height, board_length, tile_border_size, board_position_matrix)
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		board_matrix[randi_range(0, board_height - 1)][randi_range(0, board_length - 1)] += 1
		print(board_matrix)

func board_grid_generator(height: int, length: int) -> void:
	#Creates a square matrix filled with zeros with the size we want
	for i in range(height):
		var board_array_creator: Array
		for j in range(length):
			board_array_creator.append(0)
		board_matrix.append(board_array_creator)
		

func board_position_generator(height: int, length: int, tile_size: int) -> void:
	#Creates the matrix that has all the centers of the tiles
	var x_start: int = round(tile_size/2)
	var y_start: int = round(tile_size/2)
	
	for i in range(height):
		var position_array_creator: Array
		for j in range(length):
			position_array_creator.append(Vector2((x_start + j * tile_size),(y_start + i * tile_size)))
		board_position_matrix.append(position_array_creator)
		

func tile_generator(height: int, length: int, tile_size: int, positions: Array) -> void:
	#Creates the interectable tiles for the board
	var scaling: float = tile_size/(2.0*10.0)
	
	for i in range(height):
		for j in range(length):
			var tile = tile_scene.instantiate()
			
			add_child(tile)
			tile.position = positions[i][j]
			tile.scale *= scaling
	
	
	
