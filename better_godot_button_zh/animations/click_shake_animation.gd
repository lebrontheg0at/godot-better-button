@tool
extends 按钮动画基类
class_name 点击抖动动画

# 悬停/按下/点击时左右旋转抖动按钮

@export_group("参数")
@export var 抖动角度: float = 5.0
@export var 抖动次数: int = 3


func _init() -> void:
	点击时播放 = true
	时长 = 0.2
