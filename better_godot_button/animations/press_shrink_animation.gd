@tool
extends ButtonAnimation
class_name PressShrinkAnimation

# Shrinks the button on hover / press / click

@export_group("Params")
@export var shrink_factor: float = 0.95
@export var easing: Tween.EaseType = Tween.EASE_OUT
@export var transition: Tween.TransitionType = Tween.TRANS_BACK


func _init() -> void:
	play_on_press = true
	duration = 0.1
