extends Node2D
class_name EyePacker

const QUADRANT_COUNT: int = 4
const QUADRANT_ANGLE_STEP: float = PI * 0.5

@export var start_ring_radius: float = 700.0
@export var angular_buffer: float = 0.02
@export var spawn_wait: float = 0.16
@export_range(1, 20, 1) var spawn_per_cycle: int = 1
@export_range(1, 2000, 1) var max_active_eyes: int = 150
@export var spawn_overlap_padding: float = 1.15
@export_range(1, 64, 1) var spawn_position_attempts: int = 24
@export_range(0, 64, 1) var spawn_radius_push_attempts: int = 10
@export var spawn_radius_push_step: float = 40.0
@export var small_spawn_padding_multiplier: float = 0.78
@export var large_spawn_padding_multiplier: float = 1.0
@export_range(0, 8, 1) var extra_small_spawns_per_small_pick: int = 0
@export var debug_log_spawn_sizes: bool = false
@export var debug_log_interval_seconds: float = 1.5

@onready var low_band_sprites: EyeSpriteCollection = $LowBandEyeSprites
@onready var mid_band_sprites: EyeSpriteCollection = $MidBandEyeSprites
@onready var high_band_sprites: EyeSpriteCollection = $HighBandEyeSprites

var repeat_small: bool = true

var delta_count_down: float = 0
var debug_log_countdown: float = 0
var debug_spawn_counts: Dictionary = {}
var cached_active_positions: Array[Vector2] = []
var cached_active_radii: Array[float] = []
var cached_active_padding_multipliers: Array[float] = []

var base_eye_diameter_in_px: float = Globals.base_eye_diameter_in_px
# Called when the node enters the scene tree for the first time.
func _process(delta:float)->void:
	if delta_count_down <= 0.0:
		delta_count_down = spawn_wait
		if not can_spawn_symmetry_group():
			return
		rebuild_active_collision_cache()
		for _i in spawn_per_cycle:
			if not can_spawn_symmetry_group():
				break
			var chosen_collection: EyeSpriteCollection = spawn_once_balanced_by_area()
			if chosen_collection == null:
				continue
			if is_small_collection(chosen_collection):
				for _bonus_idx in extra_small_spawns_per_small_pick:
					if not can_spawn_symmetry_group():
						break
					try_spawn_from_collection(chosen_collection)
	else:
		delta_count_down = maxf(0.0, delta_count_down - delta)

	if debug_log_spawn_sizes:
		debug_log_countdown = maxf(0.0, debug_log_countdown - delta)
		if debug_log_countdown <= 0.0:
			print_spawn_debug_summary()
			debug_log_countdown = maxf(0.1, debug_log_interval_seconds)


func spawn_once_balanced_by_area() -> EyeSpriteCollection:
	var remaining: Array[EyeSpriteCollection] = [low_band_sprites, mid_band_sprites, high_band_sprites]
	while not remaining.is_empty():
		var best_index: int = 0
		var best_area: float = get_collection_active_area(remaining[0])
		for i in range(1, remaining.size()):
			var candidate_area: float = get_collection_active_area(remaining[i])
			if candidate_area < best_area:
				best_area = candidate_area
				best_index = i
		var selected: EyeSpriteCollection = remaining[best_index]
		remaining.remove_at(best_index)
		if try_spawn_from_collection(selected):
			return selected
	return null


func get_collection_active_area(collection: EyeSpriteCollection) -> float:
	var total_area: float = 0.0
	for child in collection.in_use.get_children():
		if child is EyeSprite and child.in_use:
			var radius_px: float = child.get_actual_px_size() * 0.5
			total_area += PI * radius_px * radius_px
	return total_area


func try_spawn_from_collection(collection: EyeSpriteCollection) -> bool:
	var spawn_positions: Array[Vector2] = find_open_spawn_positions(collection.base_scale)
	if spawn_positions.is_empty():
		return false
	var sprites: Array[EyeSprite] = []
	for _idx in range(spawn_positions.size()):
		var sprite: EyeSprite = collection.pass_child_for_use()
		if not sprite:
			for spawned_sprite in sprites:
				collection.recycle_child(spawned_sprite)
			return false
		sprites.append(sprite)
	for idx in range(spawn_positions.size()):
		sprites[idx].determine_base_values(spawn_positions[idx])
	add_spawn_group_to_collision_cache(spawn_positions, collection.base_scale)
	if debug_log_spawn_sizes:
		record_spawn_debug(collection, spawn_positions.size())
	return true


func is_small_collection(collection: EyeSpriteCollection) -> bool:
	var min_scale: float = minf(low_band_sprites.base_scale, minf(mid_band_sprites.base_scale, high_band_sprites.base_scale))
	return is_equal_approx(collection.base_scale, min_scale)


func record_spawn_debug(collection: EyeSpriteCollection, increment: int = 1) -> void:
	var key: String = collection.name
	var previous_count: int = int(debug_spawn_counts.get(key, 0))
	debug_spawn_counts[key] = previous_count + increment


func print_spawn_debug_summary() -> void:
	if debug_spawn_counts.is_empty():
		return
	var low_count: int = int(debug_spawn_counts.get("LowBandEyeSprites", 0))
	var mid_count: int = int(debug_spawn_counts.get("MidBandEyeSprites", 0))
	var high_count: int = int(debug_spawn_counts.get("HighBandEyeSprites", 0))
	print("Spawn counts - low: %d, mid: %d, high: %d" % [low_count, mid_count, high_count])


func find_open_spawn_positions(base_scale: float) -> Array[Vector2]:
	var candidate_radius_px: float = base_eye_diameter_in_px * base_scale * 0.5
	var candidate_padding_multiplier: float = get_size_padding_multiplier(base_scale)
	var push_step: float = maxf(spawn_radius_push_step, candidate_radius_px * spawn_overlap_padding)
	for _attempt in spawn_position_attempts:
		var spawn_angle: float = randf() * TAU
		var spawn_radius: float = start_ring_radius + randf_range(-angular_buffer, angular_buffer) * start_ring_radius
		for push_index in range(spawn_radius_push_attempts + 1):
			var pushed_radius: float = spawn_radius + (push_step * float(push_index))
			var seed_position: Vector2 = Vector2.from_angle(spawn_angle) * pushed_radius
			var candidates: Array[Vector2] = get_quadrant_positions(seed_position)
			if are_positions_clear(candidates, candidate_radius_px, candidate_padding_multiplier):
				return candidates
	return []


func are_positions_clear(candidates: Array[Vector2], candidate_radius_px: float, candidate_padding_multiplier: float) -> bool:
	var min_candidate_separation: float = (candidate_radius_px * 2.0) * spawn_overlap_padding * candidate_padding_multiplier
	var min_candidate_separation_sq: float = min_candidate_separation * min_candidate_separation
	for i in range(candidates.size()):
		for j in range(i + 1, candidates.size()):
			if candidates[i].distance_squared_to(candidates[j]) < min_candidate_separation_sq:
				return false

	for active_index in range(cached_active_positions.size()):
		var other_position: Vector2 = cached_active_positions[active_index]
		var other_radius_px: float = cached_active_radii[active_index]
		var other_padding_multiplier: float = cached_active_padding_multipliers[active_index]
		var pair_padding_multiplier: float = (candidate_padding_multiplier + other_padding_multiplier) * 0.5
		var min_separation: float = (candidate_radius_px + other_radius_px) * spawn_overlap_padding * pair_padding_multiplier
		var min_separation_sq: float = min_separation * min_separation
		for candidate in candidates:
			if candidate.distance_squared_to(other_position) < min_separation_sq:
				return false
	return true


func get_quadrant_positions(seed_position: Vector2) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	for idx in range(QUADRANT_COUNT):
		positions.append(seed_position.rotated(QUADRANT_ANGLE_STEP * float(idx)))
	return positions


func can_spawn_symmetry_group() -> bool:
	return get_active_eye_count() + QUADRANT_COUNT <= max_active_eyes


func rebuild_active_collision_cache() -> void:
	cached_active_positions.clear()
	cached_active_radii.clear()
	cached_active_padding_multipliers.clear()
	var collections: Array[EyeSpriteCollection] = [low_band_sprites, mid_band_sprites, high_band_sprites]
	for collection in collections:
		var padding_multiplier: float = get_size_padding_multiplier(collection.base_scale)
		for child in collection.in_use.get_children():
			if child is EyeSprite and child.in_use:
				cached_active_positions.append(child.global_position)
				cached_active_radii.append(child.get_actual_px_size() * 0.5)
				cached_active_padding_multipliers.append(padding_multiplier)


func add_spawn_group_to_collision_cache(spawn_positions: Array[Vector2], base_scale: float) -> void:
	var spawn_radius_px: float = base_eye_diameter_in_px * base_scale * 0.5
	var padding_multiplier: float = get_size_padding_multiplier(base_scale)
	for spawn_position in spawn_positions:
		cached_active_positions.append(spawn_position)
		cached_active_radii.append(spawn_radius_px)
		cached_active_padding_multipliers.append(padding_multiplier)


func get_size_padding_multiplier(base_scale: float) -> float:
	var min_scale: float = minf(low_band_sprites.base_scale, minf(mid_band_sprites.base_scale, high_band_sprites.base_scale))
	var max_scale: float = maxf(low_band_sprites.base_scale, maxf(mid_band_sprites.base_scale, high_band_sprites.base_scale))
	if is_equal_approx(min_scale, max_scale):
		return 1.0
	var normalized_scale: float = inverse_lerp(min_scale, max_scale, base_scale)
	return lerpf(small_spawn_padding_multiplier, large_spawn_padding_multiplier, normalized_scale)


func get_total_eye_count() -> int:
	return low_band_sprites.get_total_count() + mid_band_sprites.get_total_count() + high_band_sprites.get_total_count()


func get_active_eye_count() -> int:
	return low_band_sprites.get_active_count() + mid_band_sprites.get_active_count() + high_band_sprites.get_active_count()
