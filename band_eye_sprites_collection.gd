extends Node2D
class_name EyeSpriteCollection

@export var base_scale: float= 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for child in get_children():
		if child is EyeSprite:
			var eye_sprite = child as EyeSprite
			if eye_sprite.in_use:
				eye_sprite.move_along_spiral(delta)


func pass_child_for_use()->EyeSprite:
	for child in get_children():
		if child is EyeSprite:
			#print("EyeSprite Found")
			if not child.in_use:
				#print("and it's not in use")
				child.scale = Vector2(base_scale,base_scale)
				child.in_use = true
				return child
	#print("About to give Null")
	return null
