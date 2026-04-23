extends Resource
class_name SkillTarget

@export var target: target_type
@export var skill_range: int

enum target_type {SELF, SINGLE_TARGET, AREA, SLICE_AREA}

func get_targets(user_position: Vector2i, height: int, length: int) -> Dictionary[int, Array]:
	var target_dictionary: Dictionary[int, Array]
	
	match target:
		target_type.SELF:
			target_dictionary[0].append(user_position)
			
		target_type.SINGLE_TARGET:
			var skill_directions: Array[Vector2i]
			for i in [-1, 0, 1]:
				for j in [-1, 0, 1]:
					if i == 0 and j == 0:
						continue
					else:
						skill_directions.append(Vector2i(i, j))
			
			var k = 0
			for n in range(1, skill_range + 1):
				for m in range(skill_directions.size()):
					var possible_target: Vector2i = user_position + n * skill_directions[m]
					if position_in_bounds(possible_target, height, length):
						target_dictionary[k].append(possible_target)
						k += 1
					else:
						continue
					
				
		target_type.AREA:
			var skill_directions: Array[Vector2i]
			for i in [-1, 0, 1]:
				for j in [-1, 0, 1]:
					if i == 0 and j == 0:
						continue
					else:
						skill_directions.append(Vector2i(i, j))
			
			for n in range(1, skill_range + 1):
				for m in range(skill_directions.size()):
					var possible_target: Vector2i = user_position + n * skill_directions[m]
					if position_in_bounds(possible_target, height, length):
						target_dictionary[0].append(possible_target)
						
					else:
						continue
					
		target_type.SLICE_AREA:
			var slice_directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
			
			var s = 0
			
			for direction in slice_directions:
				for r in range(1, skill_range + 1):
					var mod_1: Vector2i
					var mod_2: Vector2i
					
					if direction.x == 0:
						mod_1 = Vector2i.LEFT
						mod_2 = Vector2i.RIGHT
					else:
						mod_1 = Vector2i.UP
						mod_2 = Vector2i.DOWN
					
					var start_slice: Vector2i = user_position + mod_1 + (r * direction)
					var middle_slice: Vector2i = user_position + (r * direction)
					var end_slice: Vector2i = user_position + mod_2 + (r * direction)
					
					if position_in_bounds(start_slice, height, length):
						target_dictionary[s].append(start_slice)
					
					if position_in_bounds(middle_slice, height, length):
						target_dictionary[s].append(middle_slice)
					
					if position_in_bounds(end_slice, height, length):
						target_dictionary[s].append(end_slice)
					
				s += 1
		
	
	
	return target_dictionary

func position_in_bounds(pos: Vector2i, h: int, l: int) -> bool:
	return (pos.x >= 0 and pos.y >= 0 and pos.x < h and pos.y < l)
	
