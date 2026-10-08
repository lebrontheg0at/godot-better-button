# uid-marker: en-sink
@tool
extends ButtonAnimation
class_name SinkAnimation

# The whole button sinks down then floats back (press feel)

@export_group("Params")
@export var distance: float = 6.0


func _init() -> void:
	duration = 0.15
