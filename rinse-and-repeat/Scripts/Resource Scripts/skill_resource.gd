extends Resource
class_name Skill
#This is a Resource for all Skills (Not Finished)

@export var skill_name: String
@export var type: SkillType
@export var target: SkillTarget
@export var skill_description: String

var player_skill: bool
var target_dictionary: Dictionary[int, Array]

func verify_user(is_player: bool) -> void:
	player_skill = is_player
	

func verify_targets() -> void:
	pass

func execute_skill(user: CharacterClass, target: Array[Vector2i], tiles: Dictionary[Vector2i, Tile]) -> void:
	pass
