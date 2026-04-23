extends Resource
class_name Skill

@export var skill_name: String
@export var type: SkillType
@export var target: SkillTarget
@export var skill_description: String

func execute_skill(user: CharacterClass, target: Array[Vector2i], tiles: Dictionary[Vector2i, Tile]) -> void:
	pass
