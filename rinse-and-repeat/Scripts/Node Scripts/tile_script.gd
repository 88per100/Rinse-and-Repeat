extends Node2D
class_name Tile

#Since each Tile Scene has the Button on them already, onready is the best way to have it easily accessible
@onready var button: Button = $TileButton

#Most of these variables are for visual effects and are, most likely, temporary
var starting_color: Color = Color("brown")
var movement_highlight: Color = Color("green")
var attack_highlight: Color = Color("red")
var scale_up: float = 1.1
var tile_highlighted: bool = false

#These variables hold necessary logic that is told to the board
var occupied: bool = false
var player_can_move_here: bool = false
var tile_logical_position: Vector2i
var character_in_tile: int = -1

#This signal is emitted everytime a tile is pressed and it sends info to the board
signal tile_pressed(logical_position: Vector2i, character: int, movement_possible: bool)

#This is the function that emits the tile_pressed signal to the board
func _on_tile_button_pressed() -> void:
	tile_pressed.emit(tile_logical_position, character_in_tile, player_can_move_here)
	

#This function highlights the tile according to the purpose of the highlight
#It's most likely temporary
func highlight(highlight_color: Color) -> void:
	if tile_highlighted:
		pass
	else:
		modulate = highlight_color
		button.modulate = highlight_color
		scale_tween(scale_up)
		tile_highlighted = true
	

#This function undoes what the highlight function did
#This is also most likely temporary or rudementary
func un_highlight() -> void:
	if !tile_highlighted:
		pass
	else:
		modulate = starting_color
		button.modulate = starting_color
		scale_tween(1 / scale_up)
		tile_highlighted = false
	

#This function just scales the tile up or down
func scale_tween(scaling: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", self.scale * scaling, 0.2 * scaling)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.play()
	await tween.finished
	tween.kill()
	
