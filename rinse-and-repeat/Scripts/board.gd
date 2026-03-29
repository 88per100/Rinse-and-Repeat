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


const buttons_scene = preload("res://Scenes/action_buttons.tscn")
var buttons_dictionary: Dictionary

#This will bring the body of the player, which is controlled by the board
const player_body_scene = preload("res://Scenes/player_body.tscn")
var player_body: Node2D

#This will bring the enemy sprites to the board
const enemy_scene = preload("res://Scenes/enemy.tscn")
var enemy_dictionary: Dictionary


#Matrix with the center position of each tile
var board_position_matrix: Array[Array]

#Dictionary to store the Tile reference so that we can access it from the board
var tiles_reference: Dictionary

#Checks if the player is able to be selected
var player_position: Vector2i

#Checking if player is selected to move or not
var player_to_move: bool = false
var player_can_move: bool = false

#Array to store the possible tiles that the player can move to once he is ready to move
var player_movement_possibilities_calculated: bool = false
var possible_player_movements: Array[Vector2i]

func _ready() -> void:
	#Runs as soon as the board script is ran
	#Creates the board itself and places the tiles
	board_position_generator(board_height, board_length, tile_border_size)
	tile_generator(board_height, board_length, tile_border_size, board_position_matrix)
	
	#Creates the player on the Board
	player_start()
	
	#Creates objects onto the board
	object_placer(object_number, board_height, board_length)
	
	#Calculates the number of enemies for this level and creates them on the board
	LevelControl.update_level()
	enemy_start(LevelControl.enemy_number)
	
	TurnControl.turn_start()
	player_can_move = true

func _process(_delta: float) -> void:
	#To make sure it keeps being checked, since process is always running
	if !player_movement_possibilities_calculated:
		player_available_tiles_maker(PlayerControl.pace, PlayerControl.move_directions)
		
	
	if TurnControl.player_turn_over_check:
		TurnControl.turn_end()
	

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
	#Places the objects randomly on the board
	
	#These variables are essential to not let the game break due to the while loop
	#I made the number of obstacles reducable to, if impossible, it reduces the number of obstacles
	var actual_number: int = number
	#This checks if there's enough space between the new tile and all existing tiles
	var enough_space: bool = true
	#If this number reaches it's maximum, the number of actual objects gets reduced
	var iteration_monitor: int = 0
	var max_iterations: int = 100
	
	#This array stores the object positions before they're created on the board
	var object_positions: Array[Vector2i]
	
	#A while loop to make sure we get to the required/maximum amount of objects
	while object_positions.size() < actual_number:
		
		#Radomizes the object position
		var random_object_position: Vector2i = Vector2i(randi_range(0, height - 1), randi_range(0, length - 1))
		
		#A condition that checks if it's possible to place an object there
		var occupied: bool = tiles_reference[random_object_position].object_here or tiles_reference[random_object_position].is_player_here
		
		#If we've spent too much time trying to place objects, it shortens the number of objects
		#to prevent breaking the game and it skips to the next loop
		if iteration_monitor >= max_iterations:
			actual_number -= 1
			iteration_monitor = 0
			continue
		else:
			pass
		
		#If the Array is empty, we just need to check if it's occupied
		if object_positions.size() == 0:
			if !occupied:
				iteration_monitor = 0
				object_positions.append(random_object_position)
				continue
			else:
				iteration_monitor += 1
				continue
		#If the Array isn't empty, we check if the new position is in the Array
		#If not, we can check the next conditions
		elif object_positions.rfind(random_object_position) == -1:
			
			if !occupied:
				pass
			else:
				iteration_monitor += 1
				continue
			
			#Calculates the distance between the new tile and the existing ones
			#If any of them are too close to the new one, it sets the enough_space to false and breaks the loop
			#This makes it so that there aren't any consecutive objects
			for object in object_positions:
				var distance_squared: int = object.distance_squared_to(random_object_position)
				if distance_squared > 2:
					enough_space = true
				else:
					enough_space = false
					break
				
			
			if enough_space:
				object_positions.append(random_object_position)
				iteration_monitor = 0
				continue
			else:
				iteration_monitor += 1
				continue
		
		
		
	
	#Then, after getting the amount of positions necessary for the amount of objects we want,
	#we place the object there
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
	

func enemy_start(number_of_enemies: int) -> void:
	for i in range(number_of_enemies):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		
		var enemy_has_position: bool = false
		
		while !enemy_has_position:
			var random_enemy_position: Vector2i = Vector2i(randi_range(0, board_height - 1), randi_range(0, board_length - 1))
			
			var possible_tile = tiles_reference[random_enemy_position]
			var condition: bool = !possible_tile.is_player_here and !possible_tile.is_enemy_here and !possible_tile.object_here
			
			if condition:
				enemy.board_position = random_enemy_position
				tiles_reference[random_enemy_position].is_enemy_here = true
				tiles_reference[random_enemy_position].enemy_number = i
				enemy_dictionary[i] = enemy
				enemy_has_position = true
			else:
				pass
		
		enemy.position = board_position_matrix[enemy.board_position.x][enemy.board_position.y]
		enemy.scale = Vector2(0.4, 0.4)
		
		print("Enemy #{0} has spawned in {1}!".format([i+1, enemy.board_position]))
		

func _on_board_tile_pressed(_tile_position: Vector2i, player_presence: bool, movable_tile: bool, enemy_presence: bool, _enemy_index: int) -> void:
	#This function is connected to each tile and it receives the tile's position, if the player is in the tile and if it is a tile that the player can move to
	
	#This part of the function runs when the player is selected
	if player_presence and !player_to_move and player_can_move:
		
		#To make it more readable, I made functions out of what should happen in each condition
		#This function starts the player's movement
		start_player_movement(player_position, possible_player_movements)
		
		
		
	
	elif player_presence and player_to_move:
		
		stop_player_movement(player_position, possible_player_movements)
		
		create_action_buttons(PlayerControl.actions)
		
	
	#This part of the function runs if the player is selected and if he can move to the tile that was pressed
	elif player_to_move and movable_tile:
		
		#This function will stop the player's movement
		stop_player_movement(player_position, possible_player_movements)
		
		#Updates the logical and visual player position
		update_player_position(_tile_position)
		
		
		create_action_buttons(PlayerControl.actions)
		
		player_can_move = false
		
		print("Player finished his movement!")
		
	
	#This part of the function runs when player is selected, but can't move to the tile that was pressed
	elif player_to_move and enemy_presence:
		
		#This functions stops the player's movement
		stop_player_movement(player_position, possible_player_movements)
		
		
		
		print("Can't move where an Enemy is!")
		
	
	elif player_to_move:
		
		#This functions stops the player's movement
		stop_player_movement(player_position, possible_player_movements)
		
		
		
		print("Player can't move here!")
	
	elif enemy_presence:
		print("An Enemy is here!")
	
	else:
		print("Player isn't here!")
	

func start_player_movement(current_position: Vector2i, possible_tiles: Array[Vector2i]) -> void:
	#This function takes care of starting the player's actions
	
	#The player tile changes to a diferent color and becomes a bit bigger
		tiles_reference[current_position].highlight(tiles_reference[current_position].player_highlight_color)
		tiles_reference[current_position].scale *= Vector2(1.05,1.05)
		
		
		#This loop makes each tile hold the information that the player can move to it
		for unoccupied_tile in possible_tiles:
			tiles_reference[unoccupied_tile].movable_tile = true
			tiles_reference[unoccupied_tile].highlight(tiles_reference[unoccupied_tile].movement_highlight_color)
			tiles_reference[unoccupied_tile].scale *= Vector2(1.05,1.05)
			
		
		player_to_move = true
		
		print("Player is ready to move here: ")
		for i in range(possible_tiles.size()):
			print(possible_tiles[i])
	

func stop_player_movement(current_position: Vector2i, possible_tiles: Array[Vector2i]) -> void:
	#This functions will make the player movement stop when required
	
	#Resets the visual changes made to the current player tile before player moves
	tiles_reference[current_position].highlight(tiles_reference[current_position].initial_color)
	tiles_reference[current_position].scale /= Vector2(1.05,1.05)
	
	#Resets tiles that the player could move to before he moves
	for tile in possible_tiles:
		tiles_reference[tile].highlight(tiles_reference[tile].initial_color)
		tiles_reference[tile].scale /= Vector2(1.05,1.05)
		tiles_reference[tile].movable_tile = false
		
	
	#Makes so that the player stops moving (This kind of logic will be essential for turn management)
	player_to_move = false
	

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
						var condition: bool = !tiles_reference[possible_position].object_here and !tiles_reference[possible_position].is_enemy_here
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
						var condition: bool = !tiles_reference[possible_position].object_here and !tiles_reference[possible_position].is_enemy_here
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
						var condition: bool = !tiles_reference[possible_position].object_here and !tiles_reference[possible_position].is_enemy_here
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
						var condition: bool = !tiles_reference[possible_position].object_here and !tiles_reference[possible_position].is_enemy_here
						if condition:
							possible_player_movements.append(possible_position)
						else:
							break
						
					
	
	#After calculating the Array, it stops until it has to change
	player_movement_possibilities_calculated = true
	

func update_player_position(_tile_position: Vector2i) -> void:
	#This function is only called when the player actually moves to prevent issues
	
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
	
	
	

func create_action_buttons(actions: Array[String]) -> void:
	
	var number_of_buttons: int = actions.size()
	
	
	var _button_position_changers: Array[Vector2]
	
	
	for i in range(actions.size()):
		var action_button = buttons_scene.instantiate()
		
		buttons_dictionary[i] = action_button
		
		add_child(action_button)
		
		action_button.action_pressed.connect(make_action)
		
		action_button.scale = Vector2(0.6, 0.6)
		action_button.position = tiles_reference[player_position].position + Vector2(25.0, (i * 20.0) - ((number_of_buttons - 1) * 20.0))
		action_button.display_action(actions[i])
	

func delete_action_buttons() -> void:
	for i in range(buttons_dictionary.size()):
		buttons_dictionary[i].queue_free()
	

func make_action(action: String) -> void:
	PlayerControl.player_action(action)
	delete_action_buttons()
	TurnControl.player_turn_over_check = true
	player_can_move = true
	
	enemy_turn()

func enemy_turn() -> void:
	for i in range(enemy_dictionary.size()):
		var enemy = enemy_dictionary[i]
		enemy.enemy_available_tiles_maker(board_height, board_length, tiles_reference)
		var enemy_possible_movements = enemy.possible_enemy_movements
		var distance_to_player: Array[int]
		
		for enemy_possibility in enemy_possible_movements:
			distance_to_player.append(player_position.distance_squared_to(enemy_possibility))
		
		var min_index: int = distance_to_player.find(distance_to_player.min())
		var enemy_next_movement: Vector2i = enemy_possible_movements[min_index]
		enemy_movement(i, enemy.board_position , enemy_next_movement)
		
		enemy.enemy_action()
	
	player_movement_possibilities_calculated = false
	

func enemy_movement(enemy_index: int, current_position: Vector2i, next_position: Vector2i) -> void:
	
	tiles_reference[current_position].is_enemy_here = false
	tiles_reference[current_position].enemy_number = -1
	
	tiles_reference[next_position].is_enemy_here = true
	tiles_reference[next_position].enemy_number = enemy_index
	
	enemy_dictionary[enemy_index].board_position = next_position
	enemy_dictionary[enemy_index].position = board_position_matrix[next_position.x][next_position.y]
	enemy_dictionary[enemy_index].possible_enemy_movements.clear()
	
	
