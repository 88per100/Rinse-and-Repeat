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

#Dictionary to store the Tile reference so that we can access it from the board
var tiles_reference: Dictionary

#Checks if the player is able to be selected
var player_position: Vector2i

#Checking if player is selected to move or not
var player_to_move: bool = false

#Array to store the possible tiles that the player can move to once he is ready to move
var player_movement_possibilities_calculated: bool = false
var possible_player_movements: Array

func _ready() -> void:
	#Creates the board as the game loads
	board_position_generator(board_height, board_length, tile_border_size)
	tile_generator(board_height, board_length, tile_border_size, board_position_matrix)
	player_start()
	

func _process(_delta: float) -> void:
	#A while loop to make sure it keeps being checked, but need to be careful with it
	while !player_movement_possibilities_calculated:
		player_available_tiles_maker(player_control.pace)
	

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
			tile.tile_pressed.connect(_on_board_tile_pressed)
			
			tile.highlight(tile.initial_color)
			
			add_child(tile)
			
			#Adjusts position and size of the tile
			tile.position = positions[i][j]
			tile.scale *= scaling
			tile.board_position = Vector2i(i, j)
			
			#Stores a reference in a Dictionary to each Tile
			tiles_reference[Vector2i(i, j)] = tile
			
	

func player_start() -> void:
	#This function puts the player's sprite on the board
	player_body = player_body_scene.instantiate()
	add_child(player_body)
	
	#Selects a random starting position for the player on the left side of the board
	var random_starting_position = randi_range(0, board_height - 1)
	
	#Gives the information about the player position
	player_body.board_position = Vector2i(random_starting_position, 0)
	player_position = Vector2i(random_starting_position, 0)
	
	#Since wecan access each tile's information, we let each of them store if the player is there or not
	tiles_reference[Vector2i(random_starting_position, 0)].is_player_here = true
	
	#Sets initial position and the scale of the player sprite
	player_body.position = board_position_matrix[random_starting_position][0]
	player_body.scale = Vector2(0.4, 0.4)
	

#This function is connected to each tile and it receives the tile's position, if the player is in the tile and if it is a tile that the player can move to
func _on_board_tile_pressed(_tile_position: Vector2i, player_presence: bool, movable_tile: bool) -> void:
	#This part of the function runs when the player is selected
	if player_presence and !player_to_move:
		
		#The player tile changes to a diferent color and becomes a bit bigger
		tiles_reference[player_position].highlight(tiles_reference[player_position].player_highlight_color)
		tiles_reference[player_position].scale *= Vector2(1.05,1.05)
		
		#A for loop that works only on the tiles that the player can move to
		for tile in possible_player_movements:
			tiles_reference[tile].highlight(tiles_reference[tile].highlight_color)
			tiles_reference[tile].scale *= Vector2(1.05,1.05)
			
			#This makes every tile that the player can move to aware of that
			tiles_reference[tile].movable_tile = true
		
		player_to_move = true
		
		print("Player is ready to move here: ")
		for i in range(possible_player_movements.size()):
			print(possible_player_movements[i])
			
	#This part of the function runs if the player is selected and if he can move to the tile that was pressed
	elif player_to_move and movable_tile:
		
		#Resets the visual changes made to the current player tile before player moves
		tiles_reference[player_position].highlight(tiles_reference[player_position].initial_color)
		tiles_reference[player_position].scale /= Vector2(1.05,1.05)
		
		#Resets tiles that the player could move to before he moves
		for tile in possible_player_movements:
			tiles_reference[tile].highlight(tiles_reference[tile].initial_color)
			tiles_reference[tile].scale /= Vector2(1.05,1.05)
			tiles_reference[tile].movable_tile = false
		
		#Updates the logical and visual player position
		update_player_position(_tile_position)
		
		#Makes so that the player stops moving (This kind of logic will be essential for turn management)
		player_to_move = false
		print("Player finished his movement!")
	#This part of the function runs when player is selected, but can't move to the tile that was pressed
	elif player_to_move:
		
		#Resets player tile
		tiles_reference[player_position].highlight(tiles_reference[player_position].initial_color)
		tiles_reference[player_position].scale /= Vector2(1.05,1.05)
		
		#Resets tiles that player can move to
		for tile in possible_player_movements:
			tiles_reference[tile].highlight(tiles_reference[tile].initial_color)
			tiles_reference[tile].scale /= Vector2(1.05,1.05)
			tiles_reference[tile].movable_tile = false
		
		#Resets the player selection (so that another action can take place in the future)
		player_to_move = false
		print("Player can't move here!")
	else:
		print("Player isn't here!")
	

func player_available_tiles_maker(range_value: int) -> void:
	#Calculates, in 4 directions, the possible tiles the player can move to
	for reach in range(range_value + 1):
		#A value of zero is not useful for the range, so we skip it
		if reach == 0:
			continue
		
		var positive_reach: int = 0 - reach
		var negative_reach: int = 0 + reach
		
		var options: Array
		
		options.append(Vector2i(player_position + Vector2i(0, positive_reach)))
		options.append(Vector2i(player_position + Vector2i(0, negative_reach)))
		options.append(Vector2i(player_position + Vector2i(positive_reach, 0)))
		options.append(Vector2i(player_position + Vector2i(negative_reach, 0)))
		#Verifies if it is within the board and adds it the possibilities array
		for i in range(0, options.size()):
			if (options[i].x < 0) or (options[i].y < 0) or (options[i].x >= board_height) or (options[i].y >= board_length):
				pass
			else:
				possible_player_movements.append(options[i])
	
	#After calculating the Array, it stops until it has to change
	player_movement_possibilities_calculated = true
	
	

#This function is only called when the player actually moves to prevent issues
func update_player_position(_tile_position: Vector2i) -> void:
	#Player position before the move learns that the player will not be there anymore
	tiles_reference[player_position].is_player_here = false
	
	#Updates the logical position of the player
	player_position = _tile_position
	
	#New position learns that the player will be there
	tiles_reference[_tile_position].is_player_here = true
	
	#Sets the player sprite to the new position
	player_body.position = board_position_matrix[_tile_position.x][_tile_position.y]
	
	#Clears the array of the previous tiles that the player could move to
	possible_player_movements.clear()
	
	#Since the array was cleared, new positions need to be calculated, so we activate that function with this
	player_movement_possibilities_calculated = false
	
	
