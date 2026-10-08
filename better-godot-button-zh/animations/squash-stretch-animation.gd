@tool
extends 按钮动画基类
class_name 挤压拉伸动画

# 卡通式挤压拉伸（压扁-拉长-复原）

@export_group("参数")
@export var 挤压量: float = 0.2


func _init() -> void:
	时长 = 0.3
