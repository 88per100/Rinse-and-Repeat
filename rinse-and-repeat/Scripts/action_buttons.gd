extends Node2D

#Stores the action assigned to this button
var action_displayed: String

@onready var action_button: Button = $Button

#Placeholder color for easier debugging
var attack_color: Color = Color(0.929, 0.247, 0.2, 1.0)
var heal_color: Color = Color(0.339, 0.694, 0.0, 1.0)
var standard_color: Color = Color()

#This signal sends what action the button holds to the board
signal action_pressed(button_action: String)

func display_action(action: String) -> void:
	#This function displays the action on the button and its colors
	
	action_button.text = action
	action_displayed = action
	
	if action == "ATTACK":
		action_button.modulate = attack_color
	elif action == "HEAL":
		action_button.modulate = heal_color
	else:
		action_button.modulate = standard_color
	

func _on_button_pressed() -> void:
	#Just emits the signal once it's pressed
	emit_signal("action_pressed", action_displayed)
