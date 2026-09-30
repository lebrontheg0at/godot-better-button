# uid-marker: en-plugin
@tool
extends EditorPlugin

# Plugin entry: registers the "Better Button" custom type.

func _enter_tree() -> void:
	add_custom_type("Better Button", "Button", preload("better_button.gd"), preload("res://icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("Better Button")
