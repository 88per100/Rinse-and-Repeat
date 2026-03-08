extends Node2D

#Stores the matrix position of each tile
var board_position: Vector2

var is_mouse_on_tile: bool = false
signal tile_hovered(tile_position: Vector2)

func _on_tile_mouse_entered() -> void:
	is_mouse_on_tile = true
	tile_hovered.emit(board_position)

func _on_tile_mouse_exited() -> void:
	is_mouse_on_tile = false
