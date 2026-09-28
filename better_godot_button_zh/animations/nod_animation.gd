@tool
extends 按钮动画基类
class_name 点头动画

# 旋转点头（转过去再弹回来）

@export_group("参数")
@export var 点头角度: float = 10.0


func _init() -> void:
	时长 = 0.25
