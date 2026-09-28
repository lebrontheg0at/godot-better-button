@tool
extends ButtonAnimation
class_name SquashStretchAnimation

# Cartoon squash & stretch (flatten - stretch - restore)

@export_group("Params")
@export var squash_amount: float = 0.2


func _init() -> void:
	duration = 0.3
