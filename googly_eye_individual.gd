extends Node2D


@export var listen_to_band : GlobalVariables.BandValue

@onready var pupil: RigidBody2D =$Pupil

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func apply_band_signal(sig: BandSignal) -> void:
	if sig.band == listen_to_band:	
		pupil.apply_central_impulse(sig.force*1000)
