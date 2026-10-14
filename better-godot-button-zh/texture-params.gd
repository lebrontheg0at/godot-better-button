@tool
extends Resource
class_name 纹理参数

# 单个纹理状态（常规/悬停/按下）的 Sprite2D 类可调参数
# 每个属性都在 setter 里 emit_changed：自定义资源不会自动发 changed 信号，
# 少了它检查器/脚本改参数时按钮不会实时刷新

@export var 颜色: Color = Color.WHITE:
	set(值):
		颜色 = 值
		emit_changed()
@export var 偏移: Vector2 = Vector2.ZERO:
	set(值):
		偏移 = 值
		emit_changed()
@export var 缩放: Vector2 = Vector2.ONE:
	set(值):
		缩放 = 值
		emit_changed()
# 角度制，内部转弧度
@export var 旋转: float = 0.0:
	set(值):
		旋转 = 值
		emit_changed()
@export var 翻转水平: bool = false:
	set(值):
		翻转水平 = 值
		emit_changed()
@export var 翻转垂直: bool = false:
	set(值):
		翻转垂直 = 值
		emit_changed()
