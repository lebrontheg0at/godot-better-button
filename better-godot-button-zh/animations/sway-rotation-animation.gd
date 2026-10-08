@tool
extends 按钮动画基类
class_name 旋转摆动动画

# 平滑左右摇摆按钮（正弦缓动，区别于生硬的抖动）

@export_group("参数")
@export var 摆动角度: float = 6.0
@export var 次数: int = 2


func _init() -> void:
	时长 = 0.4
