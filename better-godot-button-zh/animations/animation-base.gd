@tool
extends Resource
class_name 按钮动画基类

# 所有按钮动画配置的基类：触发时机 + 通用时长

@export_group("触发时机")
@export var 悬停时播放: bool = false
@export var 按下时播放: bool = false
@export var 点击时播放: bool = false

@export var 时长: float = 0.2
