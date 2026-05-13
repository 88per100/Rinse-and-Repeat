extends Control
class_name SkillButton

@onready var button: Button = $Button

var skill_index: int

signal skill_button_pressed(index_of_skill: int)

func _ready() -> void:
	pass # Replace with function body.

func set_button_visually(user_position: Vector2, user_size: Vector2) -> void:
	var skill_button_top_position: Vector2 = user_position + Vector2(0.5 * user_position.x, -0.5 * user_position.y)
	
	var initial_button_size: Vector2 = button.size
	
	position = skill_button_top_position + skill_index * Vector2(0, initial_button_size.y)
	scale = Vector2(user_size.x *  pow(initial_button_size.x, -1), user_size.y * pow(initial_button_size.y, -1))
	

func _on_button_pressed() -> void:
	skill_button_pressed.emit(skill_index)
