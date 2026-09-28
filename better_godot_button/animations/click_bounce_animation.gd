@tool
extends ButtonAnimation
class_name ClickBounceAnimation

# Bounces the button (pop up then spring back)

@export_group("Params")
@export var bounce_scale: float = 1.2


func _init() -> void:
	play_on_click = true
	duration = 0.3
