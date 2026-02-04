extends Node2D

@onready var low_eye: Node = $LowBandEye/GooglyEye 
@onready var mid_eye: Node = $MidBandEye/GooglyEye
@onready var high_eye: Node = $HighBandEye/GooglyEye

var alternator:int =1
func _ready() -> void:
	var t := Timer.new()
	t.wait_time = 2.0
	t.autostart = true
	t.timeout.connect(_on_timer_timeout)
	add_child(t)

func _on_timer_timeout() -> void:
	trigger_child()


func trigger_child() -> void:
	var sig : BandSignal = BandSignal.new()
	if alternator == 1:
		sig.band = GlobalVariables.BandValue.LOW
		alternator = 0
	elif alternator ==0:
		sig.band = GlobalVariables.BandValue.MID
		alternator = -1
	else:
		sig.band = GlobalVariables.BandValue.HIGH
		alternator =1
	sig.force = Vector2.from_angle(randf() * TAU)
	low_eye.apply_band_signal(sig)
	mid_eye.apply_band_signal(sig)
	high_eye.apply_band_signal(sig)
