@tool
extends 按钮动画基类
class_name 悬停放大动画

# 悬停/按下/点击时放大按钮

@export_group("参数")
@export var 放大量: float = 1.1
@export var 缓动: Tween.EaseType = Tween.EASE_OUT
@export var 过渡: Tween.TransitionType = Tween.TRANS_BACK


func _init() -> void:
	悬停时播放 = true
	时长 = 0.1
