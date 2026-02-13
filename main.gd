extends Node2D

@onready var low_eye: Node = $LowBandEye/GooglyEye 
@onready var mid_eye: Node = $MidBandEye/GooglyEye
@onready var high_eye: Node = $HighBandEye/GooglyEye
@onready var central_eye: Node2D = $CentralEye
@onready var audio_service_osc = $AudioServiceOSC
@onready var eye_packer: EyePacker = $EyePacker
@onready var eye_counter_label: Label = $UI/EyeCounter

@export var band_trigger_threshold: float = 0.15
@export var show_eye_counter: bool = false
@export var eye_counter_refresh_seconds: float = 0.2
@export var default_bpm: float = 120.0
@export var beat_gate_threshold: float = 0.5
@export var band_color_rotate_every_expected_beats: int = 16

var eye_counter_refresh_countdown: float = 0.0
var seconds_per_beat: float = 0.5
var has_clock_anchor: bool = false
var next_expected_beat_time_sec: float = 0.0
var expected_beat_index: int = 0
var previous_clock_beat_value: float = 0.0
var band_color_order: Array[int] = [0, 1, 2]
var band_color_rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	audio_service_osc.endpoint_updated.connect(_on_audio_endpoint_updated)
	eye_counter_label.visible = show_eye_counter
	_set_bpm(default_bpm)
	band_color_rng.randomize()
	_randomize_band_color_order()
	_apply_band_color_rotation()
	if show_eye_counter:
		update_eye_counter()


func _process(delta: float) -> void:
	_update_expected_beat_clock()
	if show_eye_counter:
		if eye_counter_refresh_countdown <= 0.0:
			update_eye_counter()
			eye_counter_refresh_countdown = eye_counter_refresh_seconds
		else:
			eye_counter_refresh_countdown = maxf(0.0, eye_counter_refresh_countdown - delta)

func _on_audio_endpoint_updated(endpoint_name: String, value) -> void:
	var force_value: float = _to_float(value)
	match endpoint_name:
		"/clock/bpm":
			_set_bpm(force_value)
			return
		"/clock/beat":
			_handle_clock_beat(force_value)
			return

	if force_value <= band_trigger_threshold:
		return
	match endpoint_name:
		"/audio/bass":
			trigger_child(GlobalVariables.BandValue.LOW, force_value)
		"/audio/mid":
			trigger_child(GlobalVariables.BandValue.MID, force_value)
		"/audio/treble":
			trigger_child(GlobalVariables.BandValue.HIGH, force_value)


func trigger_child(band: int, force_value: float) -> void:
	var sig : BandSignal = BandSignal.new()
	sig.band = band
	sig.force = Vector2.from_angle(randf() * TAU) * clampf(force_value, 0.0, 7.0)
	low_eye.apply_band_signal(sig)
	mid_eye.apply_band_signal(sig)
	high_eye.apply_band_signal(sig)

func _to_float(value) -> float:
	if value is float:
		return value
	if value is int:
		return float(value)
	return 0.0


func update_eye_counter() -> void:
	var total_eyes: int = eye_packer.get_total_eye_count()
	var active_eyes: int = eye_packer.get_active_eye_count()
	var pooled_eyes: int = total_eyes - active_eyes
	eye_counter_label.text = "Eyes total: %d | Active: %d | Pooled: %d" % [total_eyes, active_eyes, pooled_eyes]


func _set_bpm(bpm_value: float) -> void:
	var safe_bpm: float = maxf(bpm_value, 1.0)
	seconds_per_beat = 60.0 / safe_bpm


func _handle_clock_beat(beat_value: float) -> void:
	# Use the clock beat only as phase alignment; movement timing is predicted from BPM.
	var rising_edge: bool = previous_clock_beat_value <= beat_gate_threshold and beat_value > beat_gate_threshold
	previous_clock_beat_value = beat_value
	if not rising_edge:
		return

	has_clock_anchor = true
	expected_beat_index = 1
	next_expected_beat_time_sec = _now_sec() + seconds_per_beat

	_on_expected_beat_hit()


func _update_expected_beat_clock() -> void:
	if not has_clock_anchor:
		return

	var now_sec: float = _now_sec()
	var safety_steps: int = 0
	while now_sec >= next_expected_beat_time_sec and safety_steps < 8:
		expected_beat_index += 1
		_on_expected_beat_hit()
		next_expected_beat_time_sec += seconds_per_beat
		safety_steps += 1


func _now_sec() -> float:
	return Time.get_ticks_msec() / 1000.0


func _on_expected_beat_hit() -> void:
	# Hit on odd beats only: 1 and 3 in 4/4.
	if expected_beat_index % 2 == 1:
		central_eye.trigger_beat(1.0)

	var rotate_interval: int = max(1, band_color_rotate_every_expected_beats)
	if expected_beat_index % rotate_interval == 0:
		_randomize_band_color_order()
		_apply_band_color_rotation()


func _apply_band_color_rotation() -> void:
	# Keep RGB symmetric: each band always gets a unique color slot.
	low_eye.set_color_pulse_palette_index(band_color_order[0])
	mid_eye.set_color_pulse_palette_index(band_color_order[1])
	high_eye.set_color_pulse_palette_index(band_color_order[2])


func _randomize_band_color_order() -> void:
	band_color_order = [0, 1, 2]
	for i in range(band_color_order.size() - 1, 0, -1):
		var j: int = band_color_rng.randi_range(0, i)
		var tmp: int = band_color_order[i]
		band_color_order[i] = band_color_order[j]
		band_color_order[j] = tmp
