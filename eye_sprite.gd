extends Sprite2D
class_name EyeSprite

@export var in_use: bool = false

@onready var parent_collection = $".." 

var base_angle: float
var base_radius: float

var process_angle: float
var process_radius: float

var needs_base_determination: bool = true;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	determine_base_values()
	
func move_along_spiral(delta: float)->void:
	if not needs_base_determination:	
		process_radius = maxf(0.0,process_radius-Globals.spiral_inward_speed*delta)
		process_angle += Globals.spiral_rotation_speed *delta
		global_position = Vector2(cos(process_angle), sin(process_angle))*process_radius
		var scale_size: float = (parent_collection.base_scale)
		scale = Vector2(process_radius/400, process_radius/400)
	
func determine_base_values()->void:
	base_angle = global_position.angle()
	base_radius = global_position.length()
	process_angle = base_angle
	process_radius = base_radius
	needs_base_determination = false;


func get_actual_px_size()->float:
	return (texture.get_size().x*scale.x+texture.get_size().y*scale.y)/2
