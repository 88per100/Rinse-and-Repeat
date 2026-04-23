extends Node
class_name DmgCalc

static func apply_formula(user_strength: int, user_sharpness: int, target_resistance: int, skill_base_power: int) -> int:
	var res_part: float = 1 / (4 * (float(target_resistance) + 1))
	var str_part: float = pow((float(user_strength) + 1) / 2, 2)
	
	var base_crit_rate: float = 0.05
	var base_crit_mod: float = 1.5
	
	var result: float = res_part * str_part * skill_base_power + (2 * user_strength) - target_resistance
	
	if randf_range(0.0, 1.0) <= base_crit_rate + (float(user_sharpness) * 3) / 100:
		result += base_crit_mod
	
	return ceili(result)
	
