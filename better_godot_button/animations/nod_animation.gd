@tool
extends ButtonAnimation
class_name NodAnimation

# Rotates into a nod and springs back

@export_group("Params")
@export var angle: float = 10.0


func _init() -> void:
	duration = 0.25
