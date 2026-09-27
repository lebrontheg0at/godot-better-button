@tool
extends Resource
class_name 按钮纹理层

# 单个纹理层的配置（常规/悬停/按下）

@export var 名字: String = "图案"
@export var 常规纹理: Texture2D
@export var 悬停纹理: Texture2D
@export var 按下纹理: Texture2D
@export var 偏移: Vector2 = Vector2.ZERO
@export var 缩放: Vector2 = Vector2.ONE
@export var 颜色: Color = Color.WHITE
