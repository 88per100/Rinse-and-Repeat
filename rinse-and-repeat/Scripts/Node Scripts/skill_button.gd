extends Control
class_name SkillButton
#This is script for the Skill buttons

@onready var button: Button = $Button

#It holds its skill index to be able to communicate it to other parts of the game 
var skill_index: int

#This signal is here to be connected to the parent Node (any CharacterClass) that instantiates it
#And it sends the skill's index
signal skill_button_pressed(index_of_skill: int)

#This function gets called when it's instantiated to set it up visually
func set_button_visually(user_size: Vector2) -> void:
	var skill_button_top_position: Vector2 = Vector2(0.4 * user_size.x, -0.4 * user_size.y)
	
	var initial_button_size: Vector2 = button.size
	
	var scaling: float = user_size.x / initial_button_size.x
	scale *= scaling
	position = skill_button_top_position + (skill_index * Vector2(0, initial_button_size.y) + Vector2(0, initial_button_size.y / 10)) * scaling
	

#This function runs everytime the button is pressed and sends the skill_button_pressed signal
func _on_button_pressed() -> void:
	skill_button_pressed.emit(skill_index)
	
