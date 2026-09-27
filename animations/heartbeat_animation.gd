@tool
extends 按钮动画基类
class_name 心跳动画

# 心跳式双跳缩放（咚-咚 节奏）

@export_group("参数")
@export var 心跳幅度: float = 1.15
@export var 次数: int = 2


func _init() -> void:
	时长 = 0.5
