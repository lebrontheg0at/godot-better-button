# uid-marker: en-base
@tool
extends Resource
class_name ButtonAnimation

# Base class for all button animation configs: trigger timing + shared duration

@export_group("Trigger")
@export var play_on_hover: bool = false
@export var play_on_press: bool = false
@export var play_on_click: bool = false

@export var duration: float = 0.2
