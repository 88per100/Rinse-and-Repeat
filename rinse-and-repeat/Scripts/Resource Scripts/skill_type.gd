extends Resource
class_name SkillType

@export var skill_function: type
@export var effect_type: effects
@export_subgroup("If Attack:")
@export var skill_base_damage: int
@export_subgroup("If Bleed:")
@export var bleed_damage: int
@export var bleed_duration: int
@export_subgroup("If Heal:")
@export var is_gradual_healing: bool
@export var heal_amount: int
@export_range(0.0, 1.0) var heal_percentage: float
@export var is_healing_attack: bool
@export var damage_healed_ratio: float
@export_subgroup("If Buff:")
@export var buffed_stat: stats
@export var buff_ratio: float
@export var buff_duration: int
@export_subgroup("If Debuff:")
@export var debuffed_stat: stats
@export var debuff_ratio: float
@export var debuff_duration: int

enum type {STATUS, ATTACK}
enum effects {NONE, BLEED, HEAL, BUFF, DEBUFF}
enum stats {STRENGTH, RESISTANCE, SHARPNESS, AGILITY, MOVE_RANGE}

func activate_effect(user: CharacterClass, target: CharacterClass) -> void:
	pass
