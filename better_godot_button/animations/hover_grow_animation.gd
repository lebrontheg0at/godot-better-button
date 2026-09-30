# uid-marker: en-hovergrow
@tool
extends ButtonAnimation
class_name HoverGrowAnimation

# Grows the button on hover / press / click

@export_group("Params")
@export var grow_factor: float = 1.1
@export var easing: Tween.EaseType = Tween.EASE_OUT
@export var transition: Tween.TransitionType = Tween.TRANS_BACK


func _init() -> void:
	play_on_hover = true
	duration = 0.1
