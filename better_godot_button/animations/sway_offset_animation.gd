# uid-marker: en-swayoffset
@tool
extends ButtonAnimation
class_name SwayOffsetAnimation

# Rocks the button left/right horizontally

@export_group("Params")
@export var distance: float = 20.0
@export var count: int = 3


func _init() -> void:
	duration = 0.3
