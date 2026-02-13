extends Node2D
class_name EyeSpriteCollection

@export var base_scale: float= 1
@export var eye_sprite_scene: PackedScene
@export var sprite_texture: ViewportTexture

@onready var in_use : Node = $InUse
@onready var available : Node = $Available

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func pass_child_for_use()->EyeSprite:
	for child in available.get_children():
		if child is EyeSprite:
			#print("EyeSprite Found")
			if not child.in_use:
				#print("and it's not in use")
				child.scale = Vector2(base_scale,base_scale)
				child.in_use = true
				in_use.add_child(child)
				available.remove_child(child)
				return child
	var new_sprite = spawn_new_eye_to_use()
	in_use.add_child(new_sprite)
	#print("About to give Null")
	return null
	
func spawn_new_eye_to_use()->EyeSprite:
	var new_sprite: EyeSprite = eye_sprite_scene.instantiate() as EyeSprite
	new_sprite.sprite_texture = sprite_texture
	new_sprite.in_use = true
	new_sprite.scale = Vector2(base_scale,base_scale)
	return new_sprite
	
