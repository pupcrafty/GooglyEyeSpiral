extends Node2D

@onready var pupil: Sprite2D = $Pupil

@export var look_radius: float = 65.0
@export var beat_move_duration: float = 0.24

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _pupil_tween: Tween
var _target_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	_rng.randomize()


func trigger_beat(beat_strength: float = 1.0) -> void:
	var strength_scale: float = clampf(beat_strength, 0.35, 1.4)
	var angle: float = _rng.randf() * TAU
	_target_offset = Vector2.from_angle(angle) * look_radius * strength_scale

	if _pupil_tween and _pupil_tween.is_running():
		_pupil_tween.kill()

	_pupil_tween = create_tween()
	_pupil_tween.tween_property(
		pupil,
		"position",
		_target_offset,
		beat_move_duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
