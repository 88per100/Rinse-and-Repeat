extends Node2D

#Stores the matrix position of each tile
var board_position: Vector2i

#Colors for the buttons (temporary)
var initial_color: Color = Color(0.517, 0.351, 0.222, 1.0)
var movement_highlight_color: Color = Color(0.234, 0.61, 0.0, 1.0)
var player_highlight_color: Color = Color(0.0, 0.597, 1.0, 1.0)
var object_highlight_color: Color = Color(0.0, 0.0, 0.0, 1.0)

var object_here: bool = false
var is_player_here: bool = false
var movable_tile: bool = false

signal tile_pressed(tile_position: Vector2i, player_presence: bool, can_move_here: bool)

func _on_button_pressed() -> void:
	emit_signal("tile_pressed", board_position, is_player_here, movable_tile)
	

func highlight(color_vector: Color):
	$Button.modulate = Color(color_vector)
