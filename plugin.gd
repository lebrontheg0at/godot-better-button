@tool
extends EditorPlugin

# 插件入口：注册自定义类型"更好的按钮"
# 语言切换：项目设置 better_button/language（zh=中文 / en=English），改后需重启编辑器生效

const 语言设置路径 := "better_button/language"


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(语言设置路径):
		ProjectSettings.set_setting(语言设置路径, "zh")
	ProjectSettings.set_initial_value(语言设置路径, "zh")
	ProjectSettings.set_as_basic(语言设置路径, true)
	var 语言: String = ProjectSettings.get_setting(语言设置路径, "zh")
	var 类型名 := "Better Button" if 语言 == "en" else "更好的按钮"
	add_custom_type(类型名, "Button", preload("res://addons/better_godot_button/better_button.gd"), preload("res://icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("更好的按钮")
	remove_custom_type("Better Button")
