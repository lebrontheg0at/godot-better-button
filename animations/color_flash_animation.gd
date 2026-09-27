@tool
extends 按钮动画基类
class_name 颜色闪烁动画

# 着色颜色闪烁按钮（闪到指定颜色再复原）

@export_group("参数")
@export var 闪烁颜色: Color = Color(1, 0.3, 0.3, 1)
@export var 闪烁次数: int = 2


func _init() -> void:
	时长 = 0.3
