@tool
extends ButtonAnimation
class_name ColorFlashAnimation

# Flashes to a color then back to white

@export_group("Params")
@export var flash_color: Color = Color(1, 0.3, 0.3, 1)
@export var count: int = 2


func _init() -> void:
	duration = 0.3
