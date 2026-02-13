extends Node2D
class_name EyeSprite

@export var in_use: bool = false
@export var sprite_texture: ViewportTexture
@export var scale_reference_radius: float = 300.0
@export var recycle_min_px_size: float = 8.0
@export var recycle_center_radius: float = 26.0
@export var recycle_when_fully_occluded_by_center: bool = true
@export var center_occluder_radius_px: float = 160.0
@onready var sprite: Sprite2D = $BaseSprite
var base_diameter: float = Globals.base_eye_diameter_in_px

@onready var parent_collection: EyeSpriteCollection = $"../.."

var base_angle: float
var base_radius: float

var process_angle: float
var process_radius: float

var needs_base_determination: bool = true;
var recycle_pending: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = sprite_texture
	set_active_state(in_use)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_use:
		move_along_spiral(delta)


func configure_for_spawn(resolved_texture: ViewportTexture, resolved_scale: float) -> void:
	sprite_texture = resolved_texture
	sprite.texture = sprite_texture
	scale = Vector2(resolved_scale, resolved_scale)
	recycle_pending = false
	set_active_state(true)


func recycle_to_pool(pool_position: Vector2) -> void:
	needs_base_determination = true
	recycle_pending = false
	global_position = pool_position
	set_active_state(false)


func set_active_state(is_active: bool) -> void:
	in_use = is_active
	visible = is_active
	set_process(is_active)
	
func move_along_spiral(delta: float)->void:
	if not needs_base_determination:	
		process_radius = maxf(0.0,process_radius-Globals.spiral_inward_speed*delta)
		process_angle += Globals.spiral_rotation_speed *delta
		global_position = Vector2(cos(process_angle), sin(process_angle))*process_radius
		apply_scale_from_radius()
		rotation = atan2(global_position.y, global_position.x)+PI/2
		try_recycle_into_pool()
	
func determine_base_values(where: Vector2)->void:
	base_angle = where.angle()
	base_radius = where.length()
	process_angle = base_angle
	process_radius = base_radius
	needs_base_determination = false;
	recycle_pending = false
	global_position = where
	apply_scale_from_radius()


func apply_scale_from_radius() -> void:
	var scale_size: float = parent_collection.base_scale
	var radius_normalizer: float = maxf(0.001, scale_reference_radius)
	var resolved_scale: float = process_radius * scale_size / radius_normalizer
	scale = Vector2(resolved_scale, resolved_scale)


func get_actual_px_size()->float:
	return scale.x*base_diameter


func try_recycle_into_pool() -> void:
	if recycle_pending:
		return
	if recycle_when_fully_occluded_by_center and is_fully_occluded_by_center_eye():
		recycle_pending = true
		parent_collection.recycle_child(self)
		return
	var is_small_enough: bool = get_actual_px_size() <= recycle_min_px_size
	var is_close_enough: bool = process_radius <= recycle_center_radius
	if is_small_enough and is_close_enough:
		recycle_pending = true
		parent_collection.recycle_child(self)


func is_fully_occluded_by_center_eye() -> bool:
	var eye_radius_px: float = get_actual_px_size() * 0.5
	var eye_center_distance_px: float = global_position.length()
	return eye_center_distance_px + eye_radius_px <= center_occluder_radius_px
