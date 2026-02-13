extends Node2D
class_name EyeSprite

@export var in_use: bool = false
@export var sprite_texture: ViewportTexture
@onready var sprite: Sprite2D = $BaseSprite
var base_diameter = Globals.base_eye_diameter_in_px

@onready var parent_collection = $"../.." 

var base_angle: float
var base_radius: float

var process_angle: float
var process_radius: float

var needs_base_determination: bool = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture=sprite_texture
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#determine_base_values()
	if in_use:
		move_along_spiral(delta)
	pass
	
func move_along_spiral(delta: float)->void:
	if not needs_base_determination:	
		process_radius = maxf(0.0,process_radius-Globals.spiral_inward_speed*delta)
		process_angle += Globals.spiral_rotation_speed *delta
		global_position = Vector2(cos(process_angle), sin(process_angle))*process_radius
		var scale_size: float = (parent_collection.base_scale)
		scale = Vector2(process_radius*scale_size/400, process_radius*scale_size/400)
		rotation = atan2(global_position.y, global_position.x)+PI/2
	
func determine_base_values(where: Vector2)->void:
	base_angle = where.angle()
	base_radius = where.length()
	process_angle = base_angle
	process_radius = base_radius
	needs_base_determination = false;
	global_position = where


func get_actual_px_size()->float:
	return scale.x*base_diameter
