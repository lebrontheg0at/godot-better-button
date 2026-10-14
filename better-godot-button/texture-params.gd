# uid-marker: en-params
@tool
extends Resource
class_name TextureParams

# Sprite2D-like adjustable parameters for a single texture state (normal/hover/pressed)
# Every property emits changed in its setter: custom resources do not emit it automatically,
# and without it the button would not refresh live when params change in the inspector or in code

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		emit_changed()
@export var offset: Vector2 = Vector2.ZERO:
	set(value):
		offset = value
		emit_changed()
@export var scale: Vector2 = Vector2.ONE:
	set(value):
		scale = value
		emit_changed()
# Degrees, converted to radians internally
@export var rotation: float = 0.0:
	set(value):
		rotation = value
		emit_changed()
@export var flip_h: bool = false:
	set(value):
		flip_h = value
		emit_changed()
@export var flip_v: bool = false:
	set(value):
		flip_v = value
		emit_changed()
