@tool
extends Resource
class_name ButtonTextureLayer

# Configuration of a single texture layer (normal / hover / pressed)

@export var name: String = "Layer"
@export var normal_texture: Texture2D
@export var hover_texture: Texture2D
@export var pressed_texture: Texture2D
@export var offset: Vector2 = Vector2.ZERO
@export var scale: Vector2 = Vector2.ONE
@export var color: Color = Color.WHITE
