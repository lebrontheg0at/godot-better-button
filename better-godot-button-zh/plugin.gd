@tool
extends EditorPlugin

# 插件入口：注册自定义类型"更好的按钮"

func _enter_tree() -> void:
	add_custom_type("更好的按钮", "Button", preload("better-button.gd"), preload("res://icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("更好的按钮")
