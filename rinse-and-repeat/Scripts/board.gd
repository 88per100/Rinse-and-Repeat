extends Node2D

@export_category("Board Settings")
@export_group("Size and Tile Size")
@export var board_height: int
@export var board_length: int
@export var tile_border_size: int
@export_group("Interactables")
@export var object_number: int 

#This way, we can access the Tile Scene, instanciate and control it with the board
const tile_scene = preload("res://Scenes/tile_scene.tscn")

#This will bring the body of the player, which is controlled by the board
const player_body_scene = preload("res://Scenes/player_body.tscn")
var player_body: Node2D

#Matrix with the center position of each tile
var board_position_matrix: Array[Array]

#Dictionary to store the Tile reference so that we can access it from the board
var tiles_reference: Dictionary

#Checks if the player is able to be selected
var player_position: Vector2i

#Checking if player is selected to move or not
var player_to_move: bool = false

#Array to store the possible tiles that the player can move to once he is ready to move
var player_movement_possibilities_calculated: bool = false
var possible_player_movements: Array[Vector2i]

func _ready() -> void:
	#Creates the board as the game loads
	board_position_generator(board_height, board_length, tile_border_size)
	tile_generator(board_height, board_length, tile_border_size, board_position_matrix)
	player_start()
	object_placer(object_number, board_height, board_length)
	

func _process(_delta: float) -> void:
	#To make sure it keeps being checked, since process is always running
	if !player_movement_possibilities_calculated:
		player_available_tiles_maker(player_control.pace, player_control.move_directions)
	

func board_position_generator(height: int, length: int, tile_size: int) -> void:
	#Creates the matrix that has all the centers of the tiles
	var x_start: int = round(tile_size/2.0)
	var y_start: int = round(tile_size/2.0)
	
	for i in range(height):
		var position_array_creator: Array
		for j in range(length):
			position_array_creator.append(Vector2i((x_start + j * tile_size),(y_start + i * tile_size)))
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
			
		
	

func object_placer(number: int, height: int, length: int) -> void:
	
	var object_positions: Array[Vector2i]
	while object_positions.size() < number:
		var random_object_position: Vector2i = Vector2i(randi_range(0, height - 1), randi_range(0, length - 1))
		if object_positions.rfind(random_object_position) == -1:
			var occupied: bool = tiles_reference[random_object_position].object_here or tiles_reference[random_object_position].is_player_here
			if !occupied:
				object_positions.append(random_object_position)
			else:
				continue
		else:
			continue
		
	
	for pos in object_positions:
		tiles_reference[pos].object_here = true
		tiles_reference[pos].highlight(tiles_reference[pos].object_highlight_color) 
	
	print(object_positions)
	


func player_start() -> void:
	#This function puts the player's sprite on the board
	player_body = player_body_scene.instantiate()
	add_child(player_body)
	
	#Selects a random starting position for the player on the left side of the board
	var random_starting_position = randi_range(0, board_height - 1)
	
	#Gives the information about the player position
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
		
		
		#This loop makes each tile hold the information that the player can move to it
		for unoccupied_tile in possible_player_movements:
			tiles_reference[unoccupied_tile].movable_tile = true
			tiles_reference[unoccupied_tile].highlight(tiles_reference[unoccupied_tile].movement_highlight_color)
			tiles_reference[unoccupied_tile].scale *= Vector2(1.05,1.05)
			
		
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
	

func player_available_tiles_maker(range_value: int, direction_array: Array[String]) -> void:
	#Calculates, in all available directions, the possible tiles the player can move to
	for direction in direction_array:
		#We go through each direction in the possible directions the player can go
		#Each direction is stored in an Array for easier future changes of how many directioins the player can move
		match direction:
				"UP":
					for reach in range(range_value + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = player_position + Vector2i(-reach, 0)
						if possible_position.x < 0:
							break
						var condition: bool = !tiles_reference[possible_position].object_here
						if condition:
							possible_player_movements.append(possible_position)
						else:
							break
						
					
				"DOWN":
					for reach in range(range_value + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = player_position + Vector2i(reach, 0)
						if possible_position.x >= board_height:
							break
						var condition: bool = !tiles_reference[possible_position].object_here
						if condition:
							possible_player_movements.append(possible_position)
						else:
							break
						
					
				"LEFT":
					for reach in range(range_value + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = player_position + Vector2i(0, -reach)
						if possible_position.y < 0:
							break
						var condition: bool = !tiles_reference[possible_position].object_here
						if condition:
							possible_player_movements.append(possible_position)
						else:
							break
						
					
				"RIGHT":
					for reach in range(range_value + 1):
						if reach == 0:
							continue
						var possible_position: Vector2i = player_position + Vector2i(0, reach)
						if possible_position.y >= board_length:
							break
						var condition: bool = !tiles_reference[possible_position].object_here
						if condition:
							possible_player_movements.append(possible_position)
						else:
							break
						
					
	
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
	
	
