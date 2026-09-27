@tool
extends 按钮动画基类
class_name 下沉动画

# 整个按钮往下沉再浮回（按下质感）

@export_group("参数")
@export var 下沉距离: float = 6.0


func _init() -> void:
	时长 = 0.15
