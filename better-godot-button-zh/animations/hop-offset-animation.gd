@tool
extends 按钮动画基类
class_name 上下弹动动画

# 上下垂直弹动按钮

@export_group("参数")
@export var 弹动距离: float = 8.0
@export var 次数: int = 2


func _init() -> void:
	时长 = 0.3
