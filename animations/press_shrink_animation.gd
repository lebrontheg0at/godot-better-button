@tool
extends 按钮动画基类
class_name 按下缩小动画

# 悬停/按下/点击时缩小按钮

@export_group("参数")
@export var 缩小量: float = 0.95
@export var 缓动: Tween.EaseType = Tween.EASE_OUT
@export var 过渡: Tween.TransitionType = Tween.TRANS_BACK


func _init() -> void:
	按下时播放 = true
	时长 = 0.1
