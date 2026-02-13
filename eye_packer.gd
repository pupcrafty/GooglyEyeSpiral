extends Node2D
class_name EyePacker

@export var start_ring_radius: = 400
@export var angular_buffer = 0.02

@onready var low_band_sprites: EyeSpriteCollection = $LowBandEyeSprites
@onready var mid_band_sprites: EyeSpriteCollection = $MidBandEyeSprites
@onready var high_band_sprites: EyeSpriteCollection = $HighBandEyeSprites

var repeat_small = true

var delta_count_down: float = 0

var spawn_wait: float = 1.0

var base_eye_diameter_in_px=Globals.base_eye_diameter_in_px
# Called when the node enters the scene tree for the first time.
func _process(delta:float)->void:
	if delta_count_down == 0:
		delta_count_down = spawn_wait
		var options : Array[EyeSpriteCollection] = [low_band_sprites,high_band_sprites,mid_band_sprites]
		var chosen_collection = options.pick_random()
		var sprite : EyeSprite  = chosen_collection.pass_child_for_use()
		if sprite:
			sprite.determine_base_values(Vector2(500,500))
	else:
		delta_count_down = clampf(delta_count_down-delta, 0.0, 1)
	
