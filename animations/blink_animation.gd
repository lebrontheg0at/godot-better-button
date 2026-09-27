@tool
extends 按钮动画基类
class_name 闪烁动画

# 透明度闪烁按钮

@export_group("参数")
@export var 最低透明度: float = 0.3
@export var 闪烁次数: int = 3


func _init() -> void:
	时长 = 0.4
