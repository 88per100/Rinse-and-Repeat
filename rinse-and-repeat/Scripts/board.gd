extends Node2D

@export_category("Board Settings")
@export_group("Testing Size")
@export var board_size_tester: board_sizes_enum
@export_group("Dimensions Dictionary")
@export var board_sizes: Dictionary = {
	board_sizes_enum.SMALL:
		[3, 5, 80],
	board_sizes_enum.MEDIUM:
		[5, 8, 70],
	board_sizes_enum.LARGE:
		[7, 10, 60]
}
@export_group("Interactables")
@export var object_number_array: Array[int] = [3, 6, 9]

enum board_sizes_enum {
	SMALL, 
	MEDIUM, 
	LARGE
}

var board_height: int
var board_length: int
var tile_border_size: int
var object_number: int

#This way, we can access the Tile Scene, instanciate and control it with the board
const tile_scene = preload("uid://d1a0dgxso6m6h")

const turn_control_scene = preload("uid://cb7uicqyb0161")
var turn_control: Node2D
var turn_order_array: Array[Array]
var total_actions: int

const buttons_scene = preload("uid://d1wsxknldhuaj")
var buttons_dictionary: Dictionary

#This will bring the body of the player, which is controlled by the board
const player_body_scene = preload("uid://dnl8e8j7167jk")
var player_body: Node2D

#This will bring the enemy sprites to the board
const enemy_scene = preload("uid://hcj13qqsyjcg")
var enemy_dictionary: Dictionary


#Matrix with the center position of each tile
var board_position_matrix: Array[Array]

#Dictionary to store the Tile reference so that we can access it from the board
var tiles_reference: Dictionary

#Checks if the player is able to be selected
var player_position: Vector2i

#Checking if player is selected to move or not
var player_to_move: bool = false

#Array to store the possible tiles that the player can move to once he is ready to move
var possible_player_movements: Array[Vector2i]

signal action_over()

func _ready() -> void:
	#Runs as soon as the board script is ran
	#Creates the board itself and places the tiles
	board_dimensions_getter(board_size_tester)
	board_position_generator(board_height, board_length, tile_border_size)
	tile_generator(board_height, board_length, tile_border_size, board_position_matrix)
	
	#Creates the player on the Board
	player_start()
	
	#Adds the turn scene and its logic to the board
	turn_scene_starter()
	
	#Creates objects onto the board
	object_placer(object_number, board_height, board_length)
	
	#Calculates the number of enemies for this level and creates them on the board
	LevelControl.update_level()
	enemy_start(LevelControl.enemy_number)
	
	#Resets the turn as a way to start it and makes it so it starts managing the turns
	turn_reset()
	turn_manager()
	

func _process(_delta: float) -> void:
	pass
	

func board_size_from_level():
	#TO BE SET UP LATER [:
	pass

func board_dimensions_getter(board_size: board_sizes_enum) -> void:
	#This function will be changed later as well
	#Right now, it just gets the dimensions from where that information is stored
	board_height = board_sizes[board_size][0]
	board_length = board_sizes[board_size][1]
	tile_border_size = board_sizes[board_size][2]
	object_number = object_number_array[board_size]
	

func board_position_generator(height: int, length: int, tile_size: int) -> void:
	#Creates the matrix that has all the positions of the tiles
	
	#This gets the actual size of the screen
	var screen_length: float = get_viewport_rect().end.x
	var screen_height: float = get_viewport_rect().end.y
	
	#The tiles starting position so that the board is centered
	var x_start: float = (screen_length/2.0) - ((length/2.0) * tile_size) + (tile_size/2.0)
	var y_start: float = (screen_height/2.0) - ((height/2.0) * tile_size) + (tile_size/2.0)
	
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
			
			add_child(tile)
			
			tile.highlight(tile.initial_color)
			
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
	

func turn_scene_starter() -> void:
	#This function instantiates and adds some of the turn logic to the board
	#It also has, currently, a label to keep track of the turns
	
	turn_control = turn_control_scene.instantiate()
	add_child(turn_control)
	
	turn_control.scale *= 1.1
	turn_control.position += Vector2(5.0, 5.0)
	

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
	
	#Sets initial position of the player sprite
	player_body.position = board_position_matrix[random_starting_position][0]
	
	#Player's Scale is adjusted according to the dimensions of the board
	player_body.scale *= 5 * tile_border_size/(get_viewport_rect().end.y)
	

func enemy_start(number_of_enemies: int) -> void:
	#This function gets the number of enemies from LevelControl and adds that number of enemies to the board
	
	for i in range(number_of_enemies):
		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		
		#For now, I have the agility being random for easier testing
		enemy.agility = randi_range(1, 10)
		
		#This variable makes sure that the enemy has a position before going to the next enemy
		#A bit risky right now, because I don't have a safeguard for the while loop
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
		
		
		#Sets position and scaling of the enemy
		enemy.position = board_position_matrix[enemy.board_position.x][enemy.board_position.y]
		enemy.scale *= 2 * tile_border_size/(get_viewport_rect().end.y)
		
		print("Enemy #{0} has {1} Agility!".format([i+1, enemy.agility]))
	

func _on_board_tile_pressed(_tile_position: Vector2i, movable_tile: bool, enemy_presence: bool, _enemy_index: int) -> void:
	#This function is connected to each tile and it receives the tile's position, if the player is in the tile and if it is a tile that the player can move to
	
	#This part of the function runs if the player is selected and if he can move to the tile that was pressed
	if player_to_move and movable_tile:
		#This function will stop the player's movement
		stop_player_movement(possible_player_movements)
		
		#Updates the logical and visual player position
		update_player_position(_tile_position)
		
		#Player can do its actions after moving, so it's only available after moving
		create_action_buttons(PlayerControl.actions)
		
		print("Player finished his movement!")
		
	
	#From here to the end of this function needs to be updated
	
	#This part of the function runs when player is selected, but can't move to the tile that was pressed
	elif player_to_move and enemy_presence:
		
		print("Can't move where an Enemy is!")
		
	
	elif player_to_move:
		
		print("Player can't move here!")
	
	elif enemy_presence:
		print("An Enemy is here!")
	
	else:
		print("Player isn't here!")
	

func turn_manager() -> void:
	#This function will manage how the turn goes, when it starts and when it ends
	
	#Starts with an await and a timer to give a bit of a delay between the enemy turns
	await get_tree().create_timer(0.25).timeout
	
	#This variable creation does 2 things:
	# 1 - It stores the current first position in the turn order to make that turn
	# 2 - It removes the first position from the turn order array so that the next one isn't the same
	var current_character: int = turn_order_array.pop_front()[0]
	
	#The player's index is always -1, the enemies have turns that are managed differently
	if current_character == -1:
		#It is very important that the player only calculates it's possible movements as its turn starts
		player_available_tiles_maker(PlayerControl.pace, PlayerControl.move_directions)
		start_player_movement(possible_player_movements)
		return
	else:
		enemy_turn(current_character)
		return
	

func turn_reset() -> void:
	#This function resets the turn before it can be managed
	
	#Since we're using this function as a turn 'starter' as well,
	#We have to check if this is going to be the first turn or not
	if turn_control.turn_counter == 0:
		pass
	else:
		turn_control.turn_end()
	
	#After ending the turn, we start a new one
	turn_control.turn_start()
	
	#Then, we calculate a new turn order
	turn_order_array = turn_control.turn_order_calculator(enemy_dictionary)
	total_actions = turn_order_array.size()
	print(turn_order_array)
	print(total_actions)
	

func start_player_movement(possible_tiles: Array[Vector2i]) -> void:
	#This function takes care of starting the player's actions
	
	#This loop makes each tile hold the information that the player can move to it
	for unoccupied_tile in possible_tiles:
		tiles_reference[unoccupied_tile].movable_tile = true
		tiles_reference[unoccupied_tile].highlight(tiles_reference[unoccupied_tile].movement_highlight_color)
		tiles_reference[unoccupied_tile].scale *= 1.05
		
	
	player_to_move = true
	
	print("Player is ready to move!")
	

func stop_player_movement(possible_tiles: Array[Vector2i]) -> void:
	#This functions will make the player movement stop when required
	
	#Resets tiles that the player could move to before he moves
	for tile in possible_tiles:
		tiles_reference[tile].highlight(tiles_reference[tile].initial_color)
		tiles_reference[tile].scale /= 1.05
		tiles_reference[tile].movable_tile = false
		
	
	#Makes so that the player stops moving (This kind of logic will be essential for turn management)
	player_to_move = false
	

func player_available_tiles_maker(range_value: int, direction_array: Array[String]) -> void:
	#Calculates, in all available directions, the possible tiles the player can move to
	
	possible_player_movements.append(player_position)
	
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
	

func update_player_position(_tile_position: Vector2i) -> void:
	#This function is only called when the player actually moves to prevent issues
	
	#Player position before the move learns that the player will not be there anymore
	tiles_reference[player_position].is_player_here = false
	
	#Updates the logical position of the player
	player_position = _tile_position
	
	#New position learns that the player will be there
	tiles_reference[_tile_position].is_player_here = true
	
	#Sets the player sprite to the new position
	#Now with a tween to make it more 'real'
	movement_tween(player_body, "position", board_position_matrix[_tile_position.x][_tile_position.y])
	
	#Clears the array of the previous tiles that the player could move to
	possible_player_movements.clear()
	

func movement_tween(object: Object, property: NodePath, target_value: Vector2) -> void:
	#This function creates the tween that runs on every movement
	#To be optimized
	
	var move_tween: Tween = create_tween()
	move_tween.tween_property(object, property, target_value, 0.3)
	move_tween.set_trans(Tween.TRANS_CUBIC)
	move_tween.play()
	await move_tween.finished
	move_tween.kill()
	

func create_action_buttons(actions: Array[String]) -> void:
	#This function creates the action buttons for the player to be able to do a function
	
	var number_of_buttons: int = actions.size()
	var spacing: float = (tile_border_size / 2.0) * (get_viewport_rect().end.y / get_viewport_rect().end.x)
	
	for i in range(actions.size()):
		var action_button = buttons_scene.instantiate()
		
		#We store their reference to keep an easy way to access them to do the respective actions
		#And to delete them later
		buttons_dictionary[i] = action_button
		
		add_child(action_button)
		
		#We connect this signal that comes from the buttons so the boards knows which one was clicked
		action_button.action_pressed.connect(make_action)
		
		action_button.scale *= 6 * tile_border_size/(get_viewport_rect().end.y * number_of_buttons)
		action_button.position = tiles_reference[player_position].position + Vector2(spacing * 1.5, (i * spacing) - ((number_of_buttons - 1) * spacing))
		action_button.display_action(actions[i])
	

func delete_action_buttons() -> void:
	#After doing the action, this funciton deletes the buttons
	for i in range(buttons_dictionary.size()):
		buttons_dictionary[i].queue_free()
	

func make_action(action: String) -> void:
	#Sends the information about the action to be performed to the PlayerControl
	#In early stages for now
	#After the Player's action, it deletes the buttons and sends a signal for the board to know that
	#the Player's turn is over
	PlayerControl.player_action(action)
	delete_action_buttons()
	action_over.emit()
	

func enemy_turn(enemy_index: int) -> void:
	#Runs the turn of the enemy selected
	
	var enemy = enemy_dictionary[enemy_index]
	enemy.enemy_available_tiles_maker(board_height, board_length, tiles_reference)
	var enemy_possible_movements = enemy.possible_enemy_movements
	var distance_to_player: Array[int]
	
	#Calculates the distance to the player
	for enemy_possibility in enemy_possible_movements:
		distance_to_player.append(player_position.distance_squared_to(enemy_possibility))
	
	#Checks what the minimum distance to the player is and makes it the next movement
	var min_index: int = distance_to_player.find(distance_to_player.min())
	var enemy_next_movement: Vector2i = enemy_possible_movements[min_index]
	
	#Makes the enemy move
	enemy_movement(enemy_index, enemy.board_position , enemy_next_movement)
	
	#After moving, the enemy does it's action
	enemy.enemy_action(enemy_index)
	action_over.emit()
	

func enemy_movement(enemy_index: int, current_position: Vector2i, next_position: Vector2i) -> void:
	#This functions works basically the same as the player movement
	
	tiles_reference[current_position].is_enemy_here = false
	tiles_reference[current_position].enemy_number = -1
	
	tiles_reference[next_position].is_enemy_here = true
	tiles_reference[next_position].enemy_number = enemy_index
	
	enemy_dictionary[enemy_index].board_position = next_position
	movement_tween(enemy_dictionary[enemy_index], "position", board_position_matrix[next_position.x][next_position.y])
	enemy_dictionary[enemy_index].possible_enemy_movements.clear()
	

func _on_action_over() -> void:
	#This function runs every time the action_over signal is sent
	#Since the turns of both player and enemy end after they do an action,
	# this function checks how many actions are left for the turn and either
	# changes turns or makes next character move
	
	print("An Action was made!")
	total_actions -= 1
	if total_actions <= 0:
		turn_reset()
		turn_manager()
	else:
		turn_manager()
	
