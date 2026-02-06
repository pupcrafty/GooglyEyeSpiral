extends Node2D
class_name EyePacker

@export var start_ring_radius: = 400
@export var angular_buffer = 0.02

@onready var low_band_sprites: EyeSpriteCollection = $LowBandEyeSprites
@onready var mid_band_sprites: EyeSpriteCollection = $MidBandEyeSprites
@onready var high_band_sprites: EyeSpriteCollection = $HighBandEyeSprites

var repeat_small = true

var base_eye_diameter_in_px=Globals.base_eye_diameter_in_px
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	place_beginning_ring()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func determine_beginning_ring_next_angle(previous_angle:float, last_placed_diameter: float, next_placed_diameter: float, sign: float)->float:
	var radius_1 = last_placed_diameter * 0.5
	var radius_2 = next_placed_diameter * 0.5
	var center_distance = radius_1 + radius_2
	if center_distance <= 0.0:
		return previous_angle
	var ratio = clampf(center_distance / (2.0 * start_ring_radius), 0.0, 1.0)
	var delta = 2.0 * asin(ratio)
	var full_angle = previous_angle + sign * (delta + angular_buffer)
	return full_angle


func place_beginning_ring()->void:
	var positive_angle: float = 0.01
	var negative_angle: float = -0.01
	var last_placed_positive_diameter = 0.0 
	var last_placed_negative_diameter = 0.0
	var last_band_selected: Globals.BandValue = Globals.BandValue.HIGH
	while positive_angle - negative_angle  < TAU/2 :
		var direction = ["positive", "negative"].pick_random()
		last_band_selected = band_determiner(positive_angle, negative_angle,last_band_selected)
		if last_band_selected != Globals.BandValue.NONE:
			var sprite: EyeSprite = get_band_child(last_band_selected)
			var twin_sprite : EyeSprite = get_band_child(last_band_selected)
			if sprite and twin_sprite:
				if direction == "positive":
					var new_angle = determine_beginning_ring_next_angle(positive_angle, last_placed_positive_diameter, sprite.get_actual_px_size(),1)
					sprite.global_position = Vector2.from_angle(new_angle)*start_ring_radius
					twin_sprite.global_position = Vector2.from_angle(new_angle+TAU/2)*start_ring_radius
					positive_angle = new_angle
					last_placed_positive_diameter = sprite.get_actual_px_size()
				else:
					var new_angle = determine_beginning_ring_next_angle(negative_angle, last_placed_negative_diameter, sprite.get_actual_px_size(),-1)
					sprite.global_position = Vector2.from_angle(new_angle)*start_ring_radius
					twin_sprite.global_position = Vector2.from_angle(new_angle-TAU/2)*start_ring_radius
					negative_angle = new_angle
					last_placed_negative_diameter = sprite.get_actual_px_size()
		else:
			positive_angle+=TAU/2
		
func band_determiner(positive_angle: float, negative_angle:float, last_band_selected: Globals.BandValue)->Globals.BandValue:
	var unusables : Array[Globals.BandValue] = what_wont_fit(positive_angle, negative_angle)
	if last_band_selected == Globals.BandValue.HIGH and unusables.find(last_band_selected) == -1:
		if repeat_small:
			repeat_small = false
			print("Repeat small...")
			return Globals.BandValue.HIGH
	unusables.append(last_band_selected)
	var selected = select_band(unusables)
	if selected == Globals.BandValue.HIGH:
		repeat_small = true
	print(selected)
	return  selected

func select_band(unselectable_bands: Array[Globals.BandValue])->Globals.BandValue:
	var options: Array[Globals.BandValue] = [Globals.BandValue.LOW, Globals.BandValue.MID, Globals.BandValue.HIGH]
	for band in unselectable_bands:
		if band == Globals.BandValue.LOW:
			options.remove_at(options.find(Globals.BandValue.LOW))
		if band == Globals.BandValue.MID:
			options.remove_at(options.find(Globals.BandValue.MID))
		if band == Globals.BandValue.HIGH:
			options.remove_at(options.find(Globals.BandValue.HIGH))	
	if options.size() >0:	
		return options.pick_random()
	else:
		return Globals.BandValue.NONE


func get_band_child(band_selected: Globals.BandValue)-> EyeSprite:
	if band_selected == Globals.BandValue.LOW:
		return low_band_sprites.pass_child_for_use()
	if band_selected == GlobalVariables.BandValue.MID:
		return mid_band_sprites.pass_child_for_use()
	if band_selected == Globals.BandValue.HIGH:
		return high_band_sprites.pass_child_for_use()
	return null

func what_wont_fit(positive_angle:float, negative_angle)->Array[Globals.BandValue]:
	var unusable_sizes:Array[Globals.BandValue] =[]
	var leftover_angle: float =PI -positive_angle + negative_angle+(angular_buffer*2)
	var width: float = 2*start_ring_radius*sin(leftover_angle/2)
	if width <= Globals.base_eye_diameter_in_px*high_band_sprites.base_scale:
		unusable_sizes.append(Globals.BandValue.HIGH)
	if width <= Globals.base_eye_diameter_in_px*mid_band_sprites.base_scale:
		unusable_sizes.append(Globals.BandValue.MID)
	if width <= Globals.base_eye_diameter_in_px*low_band_sprites.base_scale:
		unusable_sizes.append(Globals.BandValue.LOW)
	return unusable_sizes
