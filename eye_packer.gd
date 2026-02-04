extends Node2D
class_name EyePacker

@export var start_ring_radius: = 400
@export var angular_buffer = 0.02

@onready var low_band_sprites: EyeSpriteCollection = $LowBandEyeSprites
@onready var mid_band_sprites: EyeSpriteCollection = $MidBandEyeSprites
@onready var high_band_sprites: EyeSpriteCollection = $HighBandEyeSprites

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_beginning_ring()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func determine_beginning_ring_next_angle(previous_angle:float, last_placed_diameter: float, next_placed_diameter: float, sign: float)->float:
	var radius_1 = last_placed_diameter/2
	var radius_2 = next_placed_diameter/2
	var angle_part_1 =acos((2*start_ring_radius**2-radius_1**2)/(2*start_ring_radius**2))*sign
	var angle_part_2 =acos((2*start_ring_radius**2-radius_2**2)/(2*start_ring_radius**2))*sign
	print("Angle bits: ", angle_part_1, " , ", angle_part_2)
	var full_angle = previous_angle+angle_part_1+angle_part_2+angular_buffer
	return full_angle


func place_beginning_ring()->void:
	var positive_angle: float = 0.01
	var negative_angle: float = -0.01
	var last_placed_positive_diameter = 0.0 
	var last_placed_negative_diameter = 0.0
	var last_band_selected: Globals.BandValue = Globals.BandValue.HIGH
	while positive_angle - negative_angle  < TAU/2 :
		var direction = ["positive", "negative"].pick_random()
		last_band_selected = select_band(last_band_selected)
		var sprite: EyeSprite = get_band_child(last_band_selected)
		var twin_sprite : EyeSprite = get_band_child(last_band_selected)
		if sprite and twin_sprite:
			if direction == "positive":
				print("Chose Positive")
				var new_angle = determine_beginning_ring_next_angle(positive_angle, last_placed_positive_diameter, sprite.get_actual_px_size(),1)
				sprite.global_position = Vector2.from_angle(new_angle)*start_ring_radius
				twin_sprite.global_position = Vector2.from_angle(new_angle+TAU/2)*start_ring_radius
				positive_angle = new_angle
				last_placed_positive_diameter = sprite.get_actual_px_size()
			else:
				print("Chose Negative")
				var new_angle = determine_beginning_ring_next_angle(negative_angle, last_placed_positive_diameter, sprite.get_actual_px_size(),-1)
				sprite.global_position = Vector2.from_angle(new_angle)*start_ring_radius
				twin_sprite.global_position = Vector2.from_angle(new_angle-TAU/2)*start_ring_radius
				negative_angle = new_angle
				last_placed_negative_diameter = sprite.get_actual_px_size()
			print("Positive Angle: ", positive_angle)
			print("Negative Angle: ", negative_angle)
		
	
func select_band(last_band_selected: Globals.BandValue)->Globals.BandValue:
	var options: Array[Globals.BandValue] = [Globals.BandValue.LOW, Globals.BandValue.MID, Globals.BandValue.HIGH]
	if last_band_selected == Globals.BandValue.LOW:
		options.remove_at(options.find(Globals.BandValue.LOW))
	if last_band_selected == Globals.BandValue.MID:
		options.remove_at(options.find(Globals.BandValue.MID))
	if last_band_selected == Globals.BandValue.HIGH:
		options.remove_at(options.find(Globals.BandValue.HIGH))	
	return options.pick_random();


func get_band_child(band_selected: Globals.BandValue)-> EyeSprite:
	if band_selected == Globals.BandValue.LOW:
		return low_band_sprites.pass_child_for_use()
	if band_selected == GlobalVariables.BandValue.MID:
		return mid_band_sprites.pass_child_for_use()
	if band_selected == Globals.BandValue.HIGH:
		return high_band_sprites.pass_child_for_use()
	return null
