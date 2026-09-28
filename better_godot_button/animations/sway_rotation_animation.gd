@tool
extends ButtonAnimation
class_name SwayRotationAnimation

# Smooth sinusoidal rotation sway (softer than the hard shake)

@export_group("Params")
@export var angle: float = 6.0
@export var count: int = 2


func _init() -> void:
	duration = 0.4
