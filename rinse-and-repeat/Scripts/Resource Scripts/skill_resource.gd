extends Resource
class_name Skill
#This is a Resource for all Skills (Not Finished)

@export var skill_name: String
@export var type: SkillType
@export var target_type: SkillTarget
@export var skill_description: String

#This function just runs the skill_effect function from SkillType for easier coding
func execute_skill(user: CharacterClass, target: CharacterClass) -> void:
	print("{0} used {1}!".format([user.character_name, skill_name]))
	type.skill_effect(user, target)
	
