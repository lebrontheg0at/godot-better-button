# uid-marker: en-vibration
@tool
extends ButtonAnimation
class_name VibrationAnimation

# Random position jitter (screen-shake style)

@export_group("Params")
@export var distance: float = 4.0
@export var count: int = 6


func _init() -> void:
	duration = 0.25
