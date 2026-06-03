extends Node2D
class_name CharacterClass
#This is the base script for every character

#The Skill Button Scene gets preloaded to instantiate onto the Character when required
@onready var skill_button_scene: PackedScene = preload("uid://ckls8i8ojdesf")

#This enum makes it easier and safer to access the Stats
enum stats {HEALTH, STRENGTH, RESISTANCE, SHARPNESS, AGILITY, MOVE_RANGE}

@export_subgroup("Sprites & U. I.")
@export var character_name: String
@export var character_sprite: AnimatedSprite2D
@export var player_character: bool = false
@export var health_bar: ProgressBar
@export var health_colors: Array[Color] = [Color(0.0, 0.592, 0.212, 1.0), Color(0.714, 0.4, 0.063, 1.0), Color(0.6, 0.125, 0.141, 1.0)]
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

#These variables store the values in-battle of each stat
#This will be helpful for buffs, debuffs and health
var current_health: int
var current_strength: int
var current_resistance: int
var current_sharpness: int
var current_agility: int
var current_move_range: int

#These variables hold information needed for the movement and actions
#Basically anything that has to do with the board
var board_position: Vector2i
var level_index: int
var possible_movements: Array[Vector2i]
var skill_target_dictionary: Dictionary[int, Dictionary]
var skill_button_array: Array[SkillButton]

#This signal is connected to the board and gets sent everytime a skill is selected
signal skill_selected(chr_index: int, index: int, skill_range: int, skill_targets: Dictionary[int, Array])

func _ready() -> void:
	health_bar.z_index = 1
	

func _process(_delta: float) -> void:
	update_health_bar_color()
	

#This function makes it so the 'current' variables are equal to the 'max' variables when the level starts
#Since it's the start of the level and we're going to use the current variables for the interactions,
#they need a way to be initialized and set to their supposed value
#This can and will most likely be changed later
func level_start(hp: int = base_max_health) -> void:
	health_bar.max_value = base_max_health
	
	update_health(hp)
	
	current_strength = base_strength
	current_resistance = base_resistance
	current_sharpness = base_sharpness
	current_agility = base_agility
	current_move_range = move_range
	

#This function updates the character's health bar and value
func update_health(updated_health: int) -> void:
	health_tween(updated_health)
	current_health = updated_health
	

#This function keeps track of the character's health percentage and updates the health bar color
#This function is kept in the process() function to make sure it's always running and updated
func update_health_bar_color() -> void:
	if health_bar.ratio >= 0.5:
		health_bar.modulate = health_colors[0]
	elif health_bar.ratio >= 0.25:
		health_bar.modulate = health_colors[1]
	else:
		health_bar.modulate = health_colors[2]
	

#This function makes the health bar update through a tween
func health_tween(target_health: int) -> void:
	var tween = create_tween()
	tween.tween_property(health_bar, "value", target_health, 0.1)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.play()
	await tween.finished
	tween.kill()
	

#This function is responsible for the character taking damage
func take_damage(amount: int) -> void:
	var possible_health = current_health - amount
	if possible_health < 0:
		possible_health = 0
	update_health(possible_health)
	

#This function is responsible for the character healing
func gain_health(amount: int) -> void:
	var possible_health = current_health + amount
	if possible_health > base_max_health:
		possible_health = base_max_health
	update_health(possible_health)
	

#This function will be responsible for applying a debuff to the character
#Not fully functional, but the base is there
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
	

#This function will be responsible for applying a buff to the character
#Not fully functional, but the base is there
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
	

#This function will be responsible for applying bleed to the character
#It does nothing, for now tho
func bleed_effect(_strength: int, _duration: int) -> void:
	print("{0} is bleeding out!".format([character_name]))
	

#This function is responsible for calculating the positions to where the character can move to
func movement_calculator(tiles: Dictionary[Vector2i, Tile], height: int, length: int) -> void:
	#This just adds the current position to the possible positions
	possible_movements.append(board_position)
	
	#This creates an Array of length equal to the amount of movement directions filled with 'false'
	#This is so that the function can check if an obstacle is in the path of that direction
	#If it's true, no tile in that direction will be added to the resulting Array
	var obstacle_in_path: Array[bool]
	for k in movement_directions:
		obstacle_in_path.append(false)
	
	#It creates these 2 Arrays with normal and diagonal directions
	var directions: Array[Vector2i] = [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]
	var extra_directions: Array[Vector2i] = [Vector2i(1, 1), Vector2i(-1, -1), Vector2i(1, -1), Vector2i(-1, 1)]
	
	#If the character has 8 movement directions, it adds the extra directions to the original Array
	if movement_directions == 8:
		directions.append_array(extra_directions)
	else:
		pass
	
	#This outside loop goes through the movement range of the character
	for i in range(1, move_range + 1):
		#This value is the multiplier for each diagonal direction
		#This is because I want diagonal movement to be shorter than the horizontal and vertical movement
		var diag = i - 1
		
		#This is the Array that stores the temporary Vectors for the possible movements
		var possible_directions: Array[Vector2i] 
		
		#Then, it calculates each Vector with the current range value 'i'
		for dir_index in range(0, directions.size()):
			#Until it goes through the original 4 directions, it multiplies by the actual range value
			#If it only has 4 directions, than it will never be adding a diagonal
			if dir_index < 4:
				possible_directions.append(directions[dir_index] * i)
			elif diag == 0:
				continue
			else:
				possible_directions.append(directions[dir_index] * diag)
		
		#After getting the values for the range value in question, it checks if it's possible
		#to move from the character's position to the position calculated from the Vector calculated
		for j in range(possible_directions.size()):
			#Here it gets the possible position for the character
			var possible_movement: Vector2i = board_position + possible_directions[j]
			
			#If it's out of bounds, it skips to the next loop
			if (possible_movement.x < 0 or possible_movement.y < 0 or possible_movement.x >= height or possible_movement.y >= length):
				continue
			
			#Then it learns from the tile if it's occupied
			var is_tile_occupied: bool = tiles[possible_movement].occupied
			
			#If the tile is occupied, it stores that information for that direction
			if is_tile_occupied:
				obstacle_in_path[j] = true
				continue
			#If the direction is obstructed and it can't jump obstacles, it goes to the next loop
			elif obstacle_in_path[j] and !obstacle_jumper:
				continue
			#If none of the above, it's a possible new position
			else:
				possible_movements.append(possible_movement)
	

#This function instantiates and creates the buttons of the skills on the player
#As the buttons get created and instantiated, it also calculates each possibility for each skill
#This makes it so that the game already knows if a skill can be used or not 
#(in the last case, we disable the button)
func skill_button_initializer(height: int, length: int, tile_dictionary: Dictionary[Vector2i, Tile], characters: Array[CharacterClass]) -> void:
	#First, we get the character's sprite size to be able to calculate the button's size
	var sprite_size: Vector2 = character_sprite.sprite_frames.get_frame_texture("default", 0).get_size()
	
	#Then, for each of the character's skills, it creates a button
	for i in range(skills.size()):
		var current_button: SkillButton = skill_button_scene.instantiate()
		skill_button_array.append(current_button)
		add_child(current_button)
		
		current_button.skill_button_pressed.connect(_on_skill_button_pressed)
		
		var current_skill: Skill = skills[i]
		
		#This part calculates the possible targets of the skill and filters them
		#The filter obtains the positions where there actually are targets for the skill
		#At the end, it stores the dictionary of targets for each skill in another dictionary to be accessed later
		var initial_targets: Dictionary[int, Array] = current_skill.target_type.calculate_targets(board_position, height, length)
		var current_target_dictionary: Dictionary[int, Array] = skill_target_filter(initial_targets, tile_dictionary, characters, skills[i].target_type.target)
		skill_target_dictionary[i] = current_target_dictionary
		
		#The button is disabled if there are no targets for the skill
		current_button.button.disabled = !skill_possibility_checker(current_target_dictionary)
		
		current_button.skill_index = i
		current_button.button.text = current_skill.skill_name
		
		current_button.set_button_visually(sprite_size)
		
	
	#Seperately from the skills, a button for skipping the turn is created
	var skip_turn_button: SkillButton = skill_button_scene.instantiate()
	skill_button_array.append(skip_turn_button)
	add_child(skip_turn_button)
	
	skip_turn_button.skill_button_pressed.connect(_on_skill_button_pressed)
	
	skip_turn_button.skill_index = -1
	skip_turn_button.button.text = "Skip Turn"
	
	skip_turn_button.set_button_visually(sprite_size)
	

#This function runs everytime a skill button is pressed
func _on_skill_button_pressed(skill_index: int) -> void:
	#If it's the Skip Turn button, it sends specific information for it
	#It doesn't send a dictionary with targets, as you can see, but the signal sends that parameter
	#We fix that in the board_script's function that is connected to this signal
	#Instead of actually sending that dictionary, since we don't need it, that function has a default value for that parameter 
	if skill_index == -1:
		skill_selected.emit(level_index, skill_index, -1)
	#If it's an actual skill, it sends that info to the board
	else:
		skill_selected.emit(level_index, skill_index, skills[skill_index].target_type.skill_range, skill_target_dictionary[skill_index])
	
	#Then, it deletes the buttons
	for button in skill_button_array:
		button.queue_free()
		
	
	#And clears the Array where the buttons are stored
	skill_button_array.clear()
	

func npc_skill_checker(height: int, length: int, tile_dictionary: Dictionary[Vector2i, Tile], characters: Array[CharacterClass]) -> int:
	var skill_to_use: int = -1
	
	for index in range(skills.size()):
		var current_skill: Skill = skills[index]
		var initial_targets: Dictionary[int, Array] = current_skill.target_type.calculate_targets(board_position, height, length)
		var current_target_dictionary: Dictionary[int, Array] = skill_target_filter(initial_targets, tile_dictionary, characters, current_skill.target_type.target)
		
		if skill_possibility_checker(current_target_dictionary):
			skill_target_dictionary[index] = current_target_dictionary
			skill_to_use = index
			break
		else:
			continue
			
	
	return skill_to_use
	

#This function filters the possible targets that come from each target type of the skills
#And it returns the filtered Dictionary as a new Dictionary
func skill_target_filter(target_dict: Dictionary[int, Array], tile_dict: Dictionary[Vector2i, Tile], characters: Array[CharacterClass], target_type: SkillTarget.target_type) -> Dictionary[int, Array]:
	var result: Dictionary[int, Array]
	
	#Basically, it verifies if there's any valid target in the range in question
	#And, if so, it adds the whole range to the result
	for key in target_dict.keys():
		result[key] = []
		var are_targets_valid: bool = false
		
		for value in target_dict[key]:
			var tile_info: int = tile_dict[value].character_in_tile
			if tile_info == -1:
				continue
				
			#If the Skill targets the own character, it skips other verifications
			elif target_type == SkillTarget.target_type.SELF:
				are_targets_valid = true
				
			else:
				#This makes it so that the player cannot attack a player character and vice-versa
				#Because true = 1 and false = 0, the sum of these 2 values is always 1,
				# which is the condition needed for a valid target
				var valid_target: int = int(player_character) + int(characters[tile_info].player_character)
				if valid_target == 1:
					are_targets_valid = true
					break
				else:
					continue
				
			
		if are_targets_valid:
			result[key].append_array(target_dict[key])
		else:
			continue
		
	
	return result
	

#This function verifies if the skill is possible/ has any valid targets
#Basically, it just checks the filtered Dictionary and, if all Arrays are empty, it returns false
#Otherwise, it is possible, so it returns true
func skill_possibility_checker(filetered_target_dictionary: Dictionary[int, Array]) -> bool:
	var length_sum: int = 0
	
	for index in filetered_target_dictionary.keys():
		var arr_length: int = filetered_target_dictionary[index].size()
		length_sum += arr_length
	
	if length_sum == 0:
		return false
	else:
		return true
	
