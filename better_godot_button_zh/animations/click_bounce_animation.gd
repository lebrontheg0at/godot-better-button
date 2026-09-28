@tool
extends 按钮动画基类
class_name 点击弹跳动画

# 悬停/按下/点击时弹跳按钮（先弹大再弹回）

@export_group("参数")
@export var 弹跳放大量: float = 1.2


func _init() -> void:
	点击时播放 = true
	时长 = 0.3
