extends SkillType
class_name Attack
#Resource for a Basic Attack with no side effect

@export var base_damage: int

func skill_effect(user: CharacterClass,  target: CharacterClass) -> void:
	var user_str: int = user.current_strength
	var user_shr: int = user.current_sharpness
	var target_res: int = target.current_resistance
	var damage: int = DmgCalc.apply_formula(user_str, user_shr, target_res, base_damage)
	
	target.take_damage(damage)
	print("{0} took {1} damage!".format([target.character_name, damage]))
	
