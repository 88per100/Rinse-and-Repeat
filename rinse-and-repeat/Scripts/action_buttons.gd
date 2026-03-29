extends Node2D

var action_displayed: String

var attack_color: Color = Color(0.929, 0.247, 0.2, 1.0)
var heal_color: Color = Color(0.339, 0.694, 0.0, 1.0)
var standard_color: Color = Color()

signal action_pressed(button_action: String)

func display_action(action: String) -> void:
	
	$Button.text = action
	action_displayed = action
	
	if action == "ATTACK":
		$Button.modulate = attack_color
	elif action == "HEAL":
		$Button.modulate = heal_color
	else:
		$Button.modulate = standard_color
	

func _on_button_pressed() -> void:
	emit_signal("action_pressed", action_displayed)
