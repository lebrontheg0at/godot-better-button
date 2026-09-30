# uid-marker: en-hopoffset
@tool
extends ButtonAnimation
class_name HopOffsetAnimation

# Hops the button vertically

@export_group("Params")
@export var distance: float = 8.0
@export var count: int = 2


func _init() -> void:
	duration = 0.3
