extends Node2D
class_name Tile

@onready var button: Button = $TileButton

var starting_color: Color = Color("brown")
var movement_highlight: Color = Color("green")
var attack_highlight: Color = Color("red")
var scale_up: float = 1.1
var tile_highlighted: bool = false

var occupied: bool = false
var player_can_move_here: bool = false
var tile_logical_position: Vector2i
var character_in_tile: int = -1

signal tile_pressed(logical_position: Vector2i, character: int, movement_possible: bool)

func _on_tile_button_pressed() -> void:
	tile_pressed.emit(tile_logical_position, character_in_tile, player_can_move_here)
	

#Temporary visual change
func highlight(highlight_color: Color) -> void:
	if tile_highlighted:
		pass
	else:
		modulate = highlight_color
		button.modulate = highlight_color
		scale_tween(scale_up)
		tile_highlighted = true
	

func un_highlight() -> void:
	if !tile_highlighted:
		pass
	else:
		modulate = starting_color
		button.modulate = starting_color
		scale_tween(1 / scale_up)
		tile_highlighted = false
	

func scale_tween(scaling: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", self.scale * scaling, 0.2 * scaling)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.play()
	await tween.finished
	tween.kill()
	
