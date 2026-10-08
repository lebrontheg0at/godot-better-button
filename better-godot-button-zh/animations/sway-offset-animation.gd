@tool
extends 按钮动画基类
class_name 位移摇晃动画

# 左右水平摇晃按钮

@export_group("参数")
@export var 摇晃距离: float = 20.0
@export var 次数: int = 3


func _init() -> void:
	时长 = 0.3
