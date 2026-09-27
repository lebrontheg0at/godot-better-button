@tool
extends 按钮动画基类
class_name 位置震动动画

# 位置随机震动按钮（屏幕震动风格）

@export_group("参数")
@export var 震动距离: float = 4.0
@export var 震动次数: int = 6


func _init() -> void:
	时长 = 0.25
