extends Node2D
class_name EyeSpriteCollection

@export var base_scale: float = 1.0
@export var eye_sprite_scene: PackedScene
@export var sprite_texture: ViewportTexture

@onready var in_use : Node = $InUse
@onready var available : Node = $Available

const OFFSCREEN_POOL_POSITION: Vector2 = Vector2(-10000.0, -10000.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func pass_child_for_use()->EyeSprite:
	var pooled_sprite: EyeSprite = take_from_pool()
	if pooled_sprite:
		pooled_sprite.reparent(in_use)
		pooled_sprite.configure_for_spawn(sprite_texture, base_scale)
		return pooled_sprite
	var new_sprite: EyeSprite = spawn_new_eye_to_use()
	in_use.add_child(new_sprite)
	new_sprite.configure_for_spawn(sprite_texture, base_scale)
	return new_sprite
	
func spawn_new_eye_to_use()->EyeSprite:
	var new_sprite: EyeSprite = eye_sprite_scene.instantiate() as EyeSprite
	return new_sprite


func recycle_child(sprite: EyeSprite) -> void:
	if not is_instance_valid(sprite):
		return
	sprite.reparent(available)
	sprite.recycle_to_pool(OFFSCREEN_POOL_POSITION)


func take_from_pool() -> EyeSprite:
	for index in range(available.get_child_count() - 1, -1, -1):
		var child: Node = available.get_child(index)
		if child is EyeSprite:
			return child as EyeSprite
	return null


func get_total_count() -> int:
	return in_use.get_child_count() + available.get_child_count()


func get_active_count() -> int:
	return in_use.get_child_count()
	
