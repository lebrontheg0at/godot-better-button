# uid-marker: en-heartbeat
@tool
extends ButtonAnimation
class_name HeartbeatAnimation

# Double-pulse heartbeat scaling

@export_group("Params")
@export var pulse_factor: float = 1.15
@export var count: int = 2


func _init() -> void:
	duration = 0.5
