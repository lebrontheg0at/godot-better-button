# uid-marker: en-clickshake
@tool
extends ButtonAnimation
class_name ClickShakeAnimation

# Rotates the button left/right on hover / press / click

@export_group("Params")
@export var shake_angle: float = 5.0
@export var shake_count: int = 3


func _init() -> void:
	play_on_click = true
	duration = 0.2
