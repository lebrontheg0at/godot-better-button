# uid-marker: en-blink
@tool
extends ButtonAnimation
class_name BlinkAnimation

# Blinks the button via alpha

@export_group("Params")
@export var min_alpha: float = 0.3
@export var count: int = 3


func _init() -> void:
	duration = 0.4
