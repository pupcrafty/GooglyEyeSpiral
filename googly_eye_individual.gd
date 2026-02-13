extends Node2D

@export var listen_to_band: GlobalVariables.BandValue
@export var color_trigger_threshold: float = 2.4

@onready var pupil: RigidBody2D = $Pupil
@onready var back_sprite: Sprite2D = $AnimatableBody2D/BackSprite
@onready var pupil_sprite: Sprite2D = $Pupil/PupilSprite

var color_tween: Tween
var active_tint: Color = Color(1.0, 1.0, 1.0, 1.0)

const PULSE_COLORS: Array[Color] = [
	Color(1.0, 0.0, 0.0, 1.0),
	Color(0.0, 1.0, 0.0, 1.0),
	Color(0.0, 0.0, 1.0, 1.0),
]


func _ready() -> void:
	set_color_pulse_palette_index(int(listen_to_band) % PULSE_COLORS.size())


func apply_band_signal(sig: BandSignal) -> void:
	if sig.band == listen_to_band:
		pupil.apply_central_impulse(sig.force * 100.0)
		if sig.force.length() >= color_trigger_threshold:
			trigger_color_pulse()


func trigger_color_pulse() -> void:
	if color_tween and color_tween.is_running():
		color_tween.kill()

	back_sprite.modulate = active_tint
	pupil_sprite.modulate = active_tint

	color_tween = create_tween()
	color_tween.set_parallel(true)
	color_tween.tween_property(back_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	color_tween.tween_property(pupil_sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.28).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func set_color_pulse_palette_index(index: int) -> void:
	var wrapped_index: int = posmod(index, PULSE_COLORS.size())
	active_tint = PULSE_COLORS[wrapped_index]
