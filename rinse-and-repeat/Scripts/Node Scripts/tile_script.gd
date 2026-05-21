extends Node2D
class_name Tile
#This is the Script for the Tile Scene

#Since each Tile Scene has the Button and Sprite2D on them already, onready is the best way to have it easily accessible
@onready var button: Button = $TileButton
@onready var tile_sprite: Sprite2D = $TileSprite

#Most of these variables are for visual effects and are, most likely, temporary
var starting_color: Color = Color("white")
var movement_highlight: Color = Color("137deb6f")
var attack_highlight: Color = Color("ff493970")
var tile_highlighted: bool = false

#These variables hold necessary logic that is told to the board
var occupied: bool = false
var player_can_move_here: bool = false
var tile_logical_position: Vector2i
var character_in_tile: int = -1
var attack_info: Array[int] = [-1, -1, -1]

#This signal is emitted everytime a tile is pressed and it sends info to the board
signal tile_pressed(logical_position: Vector2i, character_list_index: int, movement_possible: bool, attack_information: Array[int])

#This is the function that emits the tile_pressed signal to the board
func _on_tile_button_pressed() -> void:
	tile_pressed.emit(tile_logical_position, character_in_tile, player_can_move_here, attack_info)
	

#This function highlights the tile according to the purpose of the highlight
#It's most likely temporary
func highlight(highlight_color: Color) -> void:
	if tile_highlighted:
		pass
	else:
		button.modulate = highlight_color
		modulate = highlight_color
		tile_highlighted = true
	

#This function undoes what the highlight function did
#This is also most likely temporary or rudementary
func un_highlight() -> void:
	if !tile_highlighted:
		pass
	else:
		button.modulate = Color("transparent")
		modulate = starting_color
		tile_highlighted = false
	
