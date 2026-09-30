@tool
extends Button
class_name 更好的按钮

# 多层纹理复合按钮，所有效果均为可选项
# 悬浮 = 悬停（hover）：检查器界面用"悬停"，代码内部沿用项目习惯叫"悬浮"
# 三态纹理译名：normal = 常规，hover = 悬停，press = 按下
# 纹理：基础纹理三态槽位充当默认第一层（常规/悬停/按下）；纹理层列表可追加更多层，每层同样可选三态纹理
# 动画：悬停放大/按下缩小/点击抖动/点击弹跳 四个独立配置，各自可展开勾选触发时机并调整参数
# 着色器：可选 shader，悬停时把鼠标位置写入指定 uniform
# 音效：优先用拖入的音频文件，留空则回退到 音效 自动加载节点（不存在时静默跳过）

# 开关模式：按钮变为切换式（点一下开、再点一下关）
@export var 开关模式: bool = false:
	set(值):
		开关模式 = 值
		toggle_mode = 值

@export_group("纹理")
# 默认的第一层（垫底）：拖入常规纹理即生效，悬停/按下纹理可选；追加层请用纹理层列表
@export var 常规纹理: Texture2D = null:
	set(值):
		常规纹理 = 值
		if is_inside_tree():
			_构建纹理层()
@export var 悬停纹理: Texture2D = null:
	set(值):
		悬停纹理 = 值
		if is_inside_tree():
			_构建纹理层()
@export var 按下纹理: Texture2D = null:
	set(值):
		按下纹理 = 值
		if is_inside_tree():
			_构建纹理层()

# 追加层，叠在基础纹理之上；每层都可选 常规/悬停/按下 三种纹理
@export var 纹理层列表: Array[按钮纹理层] = []:
	set(值):
		纹理层列表 = 值
		if is_inside_tree():
			_构建纹理层()

@export_group("阴影")
# 复制首层纹理垫在最底下：调黑半透明再偏移，省去手摆阴影层
@export var 启用阴影: bool = false:
	set(值):
		启用阴影 = 值
		if is_inside_tree():
			_构建纹理层()
@export var 阴影偏移: Vector2 = Vector2(5, 5):
	set(值):
		阴影偏移 = 值
		_刷新阴影()
@export var 阴影透明度: float = 0.5:
	set(值):
		阴影透明度 = 值
		_刷新阴影()

@export_group("动画")
# 每个动画可展开：勾选触发时机（悬停时/按下时/点击时播放）并调整参数
@export var 悬停放大: 悬停放大动画 = null
@export var 按下缩小: 按下缩小动画 = null
@export var 点击抖动: 点击抖动动画 = null
@export var 点击弹跳: 点击弹跳动画 = null
@export var 位移摇晃: 位移摇晃动画 = null
@export var 上下弹动: 上下弹动动画 = null
@export var 旋转摆动: 旋转摆动动画 = null
@export var 位置震动: 位置震动动画 = null
@export var 闪烁: 闪烁动画 = null
@export var 颜色闪烁: 颜色闪烁动画 = null
@export var 心跳: 心跳动画 = null
@export var 挤压拉伸: 挤压拉伸动画 = null
@export var 点头: 点头动画 = null
@export var 下沉: 下沉动画 = null

@export_group("文本")
# 勾选后自动创建文本 Label，无需手动摆节点；同名 Label 会被复用
@export var 文本节点名: String = "文本"
@export var 自动创建文本: bool = false:
	set(值):
		自动创建文本 = 值
		if is_inside_tree():
			_构建文本()
@export var 文本内容: String = "":
	set(值):
		文本内容 = 值
		# Label 不存在时也会自动补建，无需再开关一次自动创建文本
		if is_inside_tree():
			_构建文本()
@export var 文本字体: Font = null:
	set(值):
		文本字体 = 值
		_更新文本样式()
@export var 文本字号: int = 30:
	set(值):
		文本字号 = 值
		_更新文本样式()
@export var 文本颜色: Color = Color.BLACK:
	set(值):
		文本颜色 = 值
		_更新文本样式()
@export var 文本描边颜色: Color = Color.WHITE:
	set(值):
		文本描边颜色 = 值
		_更新文本样式()
@export var 文本描边大小: int = 8:
	set(值):
		文本描边大小 = 值
		_更新文本样式()

# 悬停时文本变色，离开恢复文本颜色
@export var 悬停文本颜色: Color = Color.BLACK:
	set(值):
		悬停文本颜色 = 值
		_刷新文本颜色()

# 文本投影阴影（Label 自带阴影样式）
@export var 文本阴影开关: bool = false:
	set(值):
		文本阴影开关 = 值
		_更新文本阴影()
@export var 文本阴影颜色: Color = Color(0, 0, 0, 0.588):
	set(值):
		文本阴影颜色 = 值
		_更新文本阴影()
@export var 文本阴影偏移: Vector2 = Vector2(3, 3):
	set(值):
		文本阴影偏移 = 值
		_更新文本阴影()

# 按下时文本 Label 下移，松开复位
@export var 文本偏移: Vector2 = Vector2.ZERO:
	set(值):
		文本偏移 = 值
		_刷新文本位置()
@export var 文本下移距离: float = 16.0
@export var 文本平滑下移: bool = true
@export var 文本下移时长: float = 0.05

@export_group("描边")
# 独立描边选项，启用后优先于预设/自定义 shader
@export var 启用描边: bool = false:
	set(值):
		启用描边 = 值
		if is_inside_tree():
			_构建纹理层()
# 勾选后常态无描边，悬停时才显示
@export var 悬停描边: bool = false:
	set(值):
		悬停描边 = 值
		_更新描边显示()
@export var 描边颜色: Color = Color.WHITE:
	set(值):
		描边颜色 = 值
		_更新描边参数()
@export var 描边宽度: float = 2.0:
	set(值):
		描边宽度 = 值
		_更新描边参数()

@export_group("音效")
# 直接拖入音频文件则优先播放，留空则回退到 音效 自动加载节点
@export var 悬停音效: AudioStream = null
@export var 按下音效: AudioStream = null
@export var 悬停时播放选中音效: bool = true
@export var 按下时播放音效: bool = true
# 两个音量只作用于拖入的音频文件
@export var 悬停音量: float = -10.0
@export var 按下音量: float = -10.0

@export_group("着色器")
# 内置预设，选择后直接生效，无需手动拖 shader 文件
@export_enum("无", "3D预览") var 预设着色器: int = 0:
	set(值):
		预设着色器 = 值
		if is_inside_tree():
			_构建纹理层()
# 自定义 shader，预设为"无"且未启用描边时生效
@export var 按钮着色器: Shader = null:
	set(值):
		按钮着色器 = 值
		if is_inside_tree():
			_构建纹理层()
@export var 鼠标跟随参数名: String = "mouse_screen_pos"

var _层图案: Array[Sprite2D] = []
var _阴影图案: Sprite2D = null
var _文本标签: Label = null
var _文本原始位置: Vector2 = Vector2.ZERO
var _文本动画: Tween = null
var _基础配置: 按钮纹理层 = null
var _原始大小: Vector2 = Vector2.ONE
var _悬浮动画: Tween = null
var _点击动画: Tween = null
var _抖动动画: Tween = null
var _原始位置: Vector2 = Vector2.ZERO
var _悬浮中: bool = false
var _按下中: bool = false
var _位置动画: Tween = null
var _旋转动画: Tween = null
var _闪烁动画: Tween = null

const 预设着色器列表: Array[Shader] = [
	null,
	preload("shader/preview_3d.gdshader"),
]
const 描边着色器: Shader = preload("shader/outline.gdshader")


func _ready() -> void:
	_原始大小 = scale
	_原始位置 = position
	pivot_offset = size / 2.0
	resized.connect(func():
		pivot_offset = size / 2.0
		_复位文本矩形()
		_复位图案位置()
	)
	_初始化动画配置()
	_构建纹理层()
	_构建文本()
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or not _悬浮中:
		return
	var 鼠标位置 := get_global_mouse_position()
	for 图案 in _层图案:
		if 图案.material is ShaderMaterial:
			图案.material.set_shader_parameter(鼠标跟随参数名, 鼠标位置)


func _初始化动画配置() -> void:
	# 未配置的动画用默认配置补齐（默认：悬停放大、按下缩小开启，其余关闭）
	if 悬停放大 == null:
		悬停放大 = 悬停放大动画.new()
	if 按下缩小 == null:
		按下缩小 = 按下缩小动画.new()
	if 点击抖动 == null:
		点击抖动 = 点击抖动动画.new()
	if 点击弹跳 == null:
		点击弹跳 = 点击弹跳动画.new()
	if 位移摇晃 == null:
		位移摇晃 = 位移摇晃动画.new()
	if 上下弹动 == null:
		上下弹动 = 上下弹动动画.new()
	if 旋转摆动 == null:
		旋转摆动 = 旋转摆动动画.new()
	if 位置震动 == null:
		位置震动 = 位置震动动画.new()
	if 闪烁 == null:
		闪烁 = 闪烁动画.new()
	if 颜色闪烁 == null:
		颜色闪烁 = 颜色闪烁动画.new()
	if 心跳 == null:
		心跳 = 心跳动画.new()
	if 挤压拉伸 == null:
		挤压拉伸 = 挤压拉伸动画.new()
	if 点头 == null:
		点头 = 点头动画.new()
	if 下沉 == null:
		下沉 = 下沉动画.new()


func _悬停目标倍数() -> float:
	# 悬停状态下的缩放基准倍数
	if 悬停放大 and 悬停放大.悬停时播放:
		return 悬停放大.放大量
	return 1.0


func _通用动画配置() -> Array:
	# 除放大/缩小这两个状态型动画外，其余走通用触发派发
	return [点击抖动, 点击弹跳, 位移摇晃, 上下弹动, 旋转摆动, 位置震动, 闪烁, 颜色闪烁, 心跳, 挤压拉伸, 点头, 下沉]


func _触发通用动画(时机属性: String) -> void:
	for 配置 in _通用动画配置():
		if 配置 and 配置.get(时机属性):
			_执行通用动画(配置)


func _复位通用动画() -> void:
	# 悬停结束：把通用动画动过的属性 tween 回基准状态
	var 位置被动过 := 位移摇晃 and 位移摇晃.悬停时播放 or 上下弹动 and 上下弹动.悬停时播放 			or 位置震动 and 位置震动.悬停时播放 or 下沉 and 下沉.悬停时播放
	var 旋转被动过 := 旋转摆动 and 旋转摆动.悬停时播放 or 点头 and 点头.悬停时播放
	var 透明度被动过 := 闪烁 and 闪烁.悬停时播放
	var 颜色被动过 := 颜色闪烁 and 颜色闪烁.悬停时播放
	if 位置被动过:
		if _位置动画 and is_instance_valid(_位置动画):
			_位置动画.kill()
		_位置动画 = create_tween()
		_位置动画.tween_property(self, "position", _原始位置, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if 旋转被动过:
		if _旋转动画 and is_instance_valid(_旋转动画):
			_旋转动画.kill()
		_旋转动画 = create_tween()
		_旋转动画.tween_property(self, "rotation", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if 透明度被动过 or 颜色被动过:
		if _闪烁动画 and is_instance_valid(_闪烁动画):
			_闪烁动画.kill()
		_闪烁动画 = create_tween()
		_闪烁动画.tween_property(self, "modulate", Color.WHITE, 0.15)


func _点击缩放接管() -> bool:
	# 点击触发的缩放类动画会接管缩放通道，松开时跳过还原
	for 配置 in [点击弹跳, 悬停放大, 按下缩小, 心跳, 挤压拉伸]:
		if 配置 and 配置.点击时播放:
			return true
	return false


func _执行通用动画(配置) -> void:
	var 时长: float = max(0.01, 配置.时长)
	if 配置 is 点击抖动动画:
		_播放抖动动画(配置)
	elif 配置 is 点击弹跳动画:
		_播放弹跳动画(配置)
	elif 配置 is 心跳动画:
		_播放心跳动画(配置)
	elif 配置 is 挤压拉伸动画:
		_播放挤压拉伸动画(配置)
	elif 配置 is 位移摇晃动画:
		_终止槽动画(_位置动画)
		var 基准 := _原始位置
		var 单步: float = 时长 / (配置.次数 * 2.0)
		_位置动画 = create_tween()
		for i in 配置.次数:
			_位置动画.tween_property(self, "position", 基准 + Vector2(配置.摇晃距离, 0), 单步)
			_位置动画.tween_property(self, "position", 基准 - Vector2(配置.摇晃距离, 0), 单步)
		_位置动画.tween_property(self, "position", 基准, 单步)
	elif 配置 is 上下弹动动画:
		_终止槽动画(_位置动画)
		var 基准 := _原始位置
		var 单步: float = 时长 / (配置.次数 * 2.0)
		_位置动画 = create_tween()
		for i in 配置.次数:
			_位置动画.tween_property(self, "position", 基准 + Vector2(0, -配置.弹动距离), 单步)
			_位置动画.tween_property(self, "position", 基准, 单步)
	elif 配置 is 旋转摆动动画:
		_终止槽动画(_旋转动画)
		var 单步: float = 时长 / (配置.次数 * 2.0)
		var 弧度角 := deg_to_rad(配置.摆动角度)
		_旋转动画 = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		for i in 配置.次数:
			_旋转动画.tween_property(self, "rotation", 弧度角, 单步)
			_旋转动画.tween_property(self, "rotation", -弧度角, 单步)
		_旋转动画.tween_property(self, "rotation", 0.0, 单步)
	elif 配置 is 位置震动动画:
		_终止槽动画(_位置动画)
		var 基准 := _原始位置
		var 单步: float = 时长 / (配置.震动次数 + 1.0)
		_位置动画 = create_tween()
		for i in 配置.震动次数:
			var 偏移: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 配置.震动距离
			_位置动画.tween_property(self, "position", 基准 + 偏移, 单步)
		_位置动画.tween_property(self, "position", 基准, 单步)
	elif 配置 is 闪烁动画:
		_终止槽动画(_闪烁动画)
		_闪烁动画 = create_tween()
		for i in 配置.闪烁次数:
			_闪烁动画.tween_property(self, "modulate:a", 配置.最低透明度, 时长 / (配置.闪烁次数 * 2.0))
			_闪烁动画.tween_property(self, "modulate:a", 1.0, 时长 / (配置.闪烁次数 * 2.0))
	elif 配置 is 颜色闪烁动画:
		_终止槽动画(_闪烁动画)
		_闪烁动画 = create_tween()
		for i in 配置.闪烁次数:
			_闪烁动画.tween_property(self, "modulate", 配置.闪烁颜色, 时长 / (配置.闪烁次数 * 2.0))
			_闪烁动画.tween_property(self, "modulate", Color.WHITE, 时长 / (配置.闪烁次数 * 2.0))
	elif 配置 is 点头动画:
		_终止槽动画(_旋转动画)
		var 弧度角 := deg_to_rad(配置.点头角度)
		_旋转动画 = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_旋转动画.tween_property(self, "rotation", 弧度角, 时长 * 0.6)
		_旋转动画.tween_property(self, "rotation", 0.0, 时长 * 0.4)
	elif 配置 is 下沉动画:
		_终止槽动画(_位置动画)
		var 基准 := _原始位置
		_位置动画 = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_位置动画.tween_property(self, "position", 基准 + Vector2(0, 配置.下沉距离), 时长 * 0.5)
		_位置动画.tween_property(self, "position", 基准, 时长 * 0.5)


func _终止槽动画(动画: Tween) -> void:
	if 动画 and is_instance_valid(动画):
		动画.kill()


func _当前配置() -> Array:
	# 基础纹理是默认第一层，纹理层列表的层叠在其上
	var 配置列表 := []
	if _基础配置:
		配置列表.append(_基础配置)
	配置列表.append_array(纹理层列表)
	return 配置列表


func _构建纹理层() -> void:
	# 移除上次自动创建的节点，场景里手动摆放的同名节点会被复用
	for 子节点 in get_children(true):
		if 子节点 is Sprite2D and 子节点.has_meta("plugin_created"):
			remove_child(子节点)
			子节点.free()
	_层图案.clear()
	_基础配置 = null
	if 常规纹理:
		_基础配置 = 按钮纹理层.new()
		_基础配置.名字 = "常规"
		_基础配置.常规纹理 = 常规纹理
		_基础配置.悬停纹理 = 悬停纹理
		_基础配置.按下纹理 = 按下纹理
		# 纹理默认居中于按钮
		if size != Vector2.ZERO:
			_基础配置.偏移 = size / 2.0
	for 配置 in _当前配置():
		if 配置 == null:
			continue
		var 图案 := _查找子层(配置.名字)
		if 图案 == null:
			图案 = Sprite2D.new()
			图案.name = 配置.名字
			图案.set_meta("plugin_created", true)
			# 内部节点：不在场景树面板显示，由插件全权管理
			add_child(图案, false, Node.INTERNAL_MODE_BACK)

		_层图案.append(图案)
	# 每次构建时重连信号，保证检查器里新添加的层也能实时刷新
	for 配置 in 纹理层列表:
		if 配置 and not 配置.changed.is_connected(_刷新层):
			配置.changed.connect(_刷新层)
	_刷新层()
	_构建快捷阴影()


func _构建快捷阴影() -> void:
	_阴影图案 = null
	if not 启用阴影 or _层图案.is_empty():
		return
	var 图案 := Sprite2D.new()
	图案.name = "快捷阴影"
	图案.set_meta("plugin_created", true)
	# 内部节点 + FRONT：排在最前，垫在所有层底下
	add_child(图案, false, Node.INTERNAL_MODE_FRONT)

	_阴影图案 = 图案
	_刷新阴影()
	# 首次构建时同步阴影纹理（之后由 _刷新纹理 跟随首层切换）
	if not _层图案.is_empty():
		_阴影图案.texture = _层图案[0].texture


func _刷新阴影() -> void:
	var 配置列表 := _当前配置()
	if _阴影图案 == null or not is_instance_valid(_阴影图案) or 配置列表.is_empty():
		return
	var 配置: 按钮纹理层 = 配置列表[0]
	_阴影图案.modulate = Color(0.0, 0.0, 0.0, 阴影透明度)
	_阴影图案.scale = 配置.缩放
	_阴影图案.position = 配置.偏移 + 阴影偏移


func _复位图案位置() -> void:
	# 基础层默认居中于按钮；_ready 时 size 可能还是 0，那时算出的偏移是错的，尺寸一变就重算
	if _基础配置 == null or size == Vector2.ZERO:
		return
	_基础配置.偏移 = size / 2.0
	_刷新层()
	_刷新阴影()


func _查找子层(名字: String) -> Sprite2D:
	for 子节点 in get_children(true):
		if 子节点 is Sprite2D and 子节点.name == 名字 and not 子节点.has_meta("plugin_created"):
			return 子节点
	return null


func _构建文本() -> void:
	# 优先复用场景里同名的 Label，没有且勾选了自动创建时新建
	_文本标签 = null
	for 子节点 in get_children(true):
		if 子节点 is Label and 子节点.name == 文本节点名:
			_文本标签 = 子节点
			break
	if _文本标签 == null and 自动创建文本 and not 文本内容.is_empty():
		var 标签 := Label.new()
		标签.name = 文本节点名
		标签.set_meta("plugin_created", true)
		add_child(标签, false, Node.INTERNAL_MODE_BACK)

		_文本标签 = 标签
		_更新文本样式()
	if _文本标签:
		_复位文本矩形()


func _复位文本矩形() -> void:
	# 铺满按钮并居中，复用的场景节点同样归一
	# offsets 必须显式归零：_ready 时按钮可能还是 0×0，而父节点小于 Label 最小尺寸时
	# Godot 会把最小尺寸钳进 offsets 且之后不会自行恢复，所以尺寸一变就得重来
	if _文本标签 == null or not is_instance_valid(_文本标签):
		return
	_文本标签.set_anchors_preset(Control.PRESET_FULL_RECT)
	_文本标签.offset_left = 0.0
	_文本标签.offset_top = 0.0
	_文本标签.offset_right = 0.0
	_文本标签.offset_bottom = 0.0
	_文本标签.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_文本标签.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_文本标签.z_index = 1
	_文本原始位置 = _文本标签.position
	_刷新文本位置()


func _刷新文本位置() -> void:
	if _文本标签 == null or not is_instance_valid(_文本标签):
		return
	if _文本动画 and is_instance_valid(_文本动画):
		_文本动画.kill()
	_文本标签.position = _文本原始位置 + 文本偏移


func _更新文本阴影() -> void:
	if _文本标签 == null or not is_instance_valid(_文本标签):
		return
	if 文本阴影开关:
		_文本标签.add_theme_color_override("font_shadow_color", 文本阴影颜色)
		_文本标签.add_theme_constant_override("shadow_offset_x", int(文本阴影偏移.x))
		_文本标签.add_theme_constant_override("shadow_offset_y", int(文本阴影偏移.y))
	else:
		# 关闭时用全透明阴影色清掉阴影
		_文本标签.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))


func _刷新文本颜色() -> void:
	if _文本标签 == null or not is_instance_valid(_文本标签):
		return
	_文本标签.add_theme_color_override("font_color", 悬停文本颜色 if _悬浮中 else 文本颜色)


func _更新文本样式() -> void:
	if _文本标签 == null or not is_instance_valid(_文本标签):
		return
	_文本标签.text = 文本内容
	if 文本字体:
		_文本标签.add_theme_font_override("font", 文本字体)
	_文本标签.add_theme_font_size_override("font_size", 文本字号)
	_刷新文本颜色()
	_文本标签.add_theme_color_override("font_outline_color", 文本描边颜色)
	_文本标签.add_theme_constant_override("outline_size", 文本描边大小)
	_更新文本阴影()


func _当前着色器() -> Shader:
	if 启用描边:
		return 描边着色器
	if 预设着色器 > 0:
		return 预设着色器列表[预设着色器]
	return 按钮着色器


func _更新描边显示() -> void:
	for 图案 in _层图案:
		if 图案.material is ShaderMaterial:
			图案.material.set_shader_parameter("show_outline", 1.0 if (not 悬停描边 or _悬浮中) else 0.0)


func _更新描边参数() -> void:
	for 图案 in _层图案:
		if 图案.material is ShaderMaterial:
			图案.material.set_shader_parameter("outline_color", 描边颜色)
			图案.material.set_shader_parameter("outline_width", 描边宽度)


func _刷新层() -> void:
	var 配置列表 := _当前配置()
	for i in _层图案.size():
		if i >= 配置列表.size():
			break
		var 配置: 按钮纹理层 = 配置列表[i]
		var 图案 := _层图案[i]
		图案.position = 配置.偏移
		图案.scale = 配置.缩放
		图案.modulate = 配置.颜色
		var 着色器 := _当前着色器()
		if 着色器:
			var 材质 := ShaderMaterial.new()
			材质.shader = 着色器
			材质.set_shader_parameter("outline_color", 描边颜色)
			材质.set_shader_parameter("outline_width", 描边宽度)
			材质.set_shader_parameter("show_outline", 1.0 if (not 悬停描边 or _悬浮中) else 0.0)
			图案.material = 材质
	_刷新纹理()
	_刷新阴影()


func _刷新纹理() -> void:
	var 配置列表 := _当前配置()
	for i in _层图案.size():
		if i >= 配置列表.size():
			break
		var 配置: 按钮纹理层 = 配置列表[i]
		var 目标纹理 := 配置.常规纹理
		if _按下中 and 配置.按下纹理:
			目标纹理 = 配置.按下纹理
		elif _悬浮中 and 配置.悬停纹理:
			目标纹理 = 配置.悬停纹理
		_层图案[i].texture = 目标纹理
	# 快捷阴影跟随首层纹理，保证悬停/按下切换时阴影同步
	if _阴影图案 and is_instance_valid(_阴影图案) and not _层图案.is_empty():
		_阴影图案.texture = _层图案[0].texture


func _on_mouse_entered() -> void:
	if disabled:
		return
	_悬浮中 = true
	_刷新纹理()
	_更新描边显示()
	_播放悬停音效()
	_刷新文本颜色()
	# 悬停触发的动画
	if 悬停放大 and 悬停放大.悬停时播放:
		_播放缩放动画(_原始大小 * 悬停放大.放大量, 悬停放大.时长, 悬停放大.缓动, 悬停放大.过渡)
	if 按下缩小 and 按下缩小.悬停时播放:
		_播放缩放动画(_原始大小 * 按下缩小.缩小量, 按下缩小.时长, 按下缩小.缓动, 按下缩小.过渡)
	if 点击抖动 and 点击抖动.悬停时播放:
		_播放抖动动画(点击抖动)
	_触发通用动画("悬停时播放")


func _on_mouse_exited() -> void:
	_悬浮中 = false
	# 按住时移出也要复位文本，和原版排序切换行为一致
	_播放文本下移(false)
	_更新描边显示()
	_刷新文本颜色()
	if _按下中:
		return
	_刷新纹理()
	# 悬停缩放复位
	if 悬停放大 and 悬停放大.悬停时播放:
		_播放缩放动画(_原始大小, 悬停放大.时长, 悬停放大.缓动, 悬停放大.过渡)
	elif 按下缩小 and 按下缩小.悬停时播放:
		_播放缩放动画(_原始大小, 按下缩小.时长, 按下缩小.缓动, 按下缩小.过渡)


	_复位通用动画()


func _on_button_down() -> void:
	_按下中 = true
	_刷新纹理()
	_播放文本下移(true)
	# 按下触发的动画
	if 按下缩小 and 按下缩小.按下时播放:
		_播放缩放动画(_原始大小 * 按下缩小.缩小量, 按下缩小.时长, 按下缩小.缓动, 按下缩小.过渡)
	if 悬停放大 and 悬停放大.按下时播放:
		_播放缩放动画(_原始大小 * 悬停放大.放大量, 悬停放大.时长, 悬停放大.缓动, 悬停放大.过渡)
	if 点击抖动 and 点击抖动.按下时播放:
		_播放抖动动画(点击抖动)
	if 点击弹跳 and 点击弹跳.按下时播放:
		_播放弹跳动画(点击弹跳)


	_触发通用动画("按下时播放")


func _on_button_up() -> void:
	_按下中 = false
	_刷新纹理()
	_播放文本下移(false)
	# 点击弹跳/点击缩放会接管缩放时跳过还原，避免两个缩放动画打架
	if _点击缩放接管():
		return
	# 按下缩放后复位：悬停中回到悬停大小，否则回到原始大小
	var 缩放被动过 := (按下缩小 and 按下缩小.按下时播放) or (悬停放大 and 悬停放大.按下时播放)
	if 缩放被动过:
		_播放缩放动画(_原始大小 * _悬停目标倍数(), 悬停放大.时长 if 悬停放大 else 0.1,
				悬停放大.缓动 if 悬停放大 else Tween.EASE_OUT, 悬停放大.过渡 if 悬停放大 else Tween.TRANS_BACK)


func _on_pressed() -> void:
	_播放按下音效()
	# 点击触发的动画
	if 悬停放大 and 悬停放大.点击时播放:
		_播放点击缩放动画(悬停放大.放大量)
	if 按下缩小 and 按下缩小.点击时播放:
		_播放点击缩放动画(按下缩小.缩小量)
	_触发通用动画("点击时播放")


func _播放文本下移(下移: bool) -> void:
	if _文本标签 == null or not is_instance_valid(_文本标签):
		return
	if _文本动画 and is_instance_valid(_文本动画):
		_文本动画.kill()
	var 基准 := _文本原始位置 + 文本偏移
	var 目标y := 基准.y + (文本下移距离 if 下移 else 0.0)
	if 文本平滑下移:
		_文本动画 = create_tween()
		_文本动画.set_ease(Tween.EASE_OUT)
		_文本动画.set_trans(Tween.TRANS_CUBIC)
		_文本动画.tween_property(_文本标签, "position:y", 目标y, 文本下移时长)
	else:
		# 瞬间下移，不平滑
		_文本标签.position = Vector2(基准.x, 目标y)


func _播放悬停音效() -> void:
	if not 悬停时播放选中音效:
		return
	if 悬停音效:
		_播放流(悬停音效, 悬停音量)
	else:
		_播放自动加载音效("播放选中音效")


func _播放按下音效() -> void:
	if not 按下时播放音效:
		return
	if 按下音效:
		_播放流(按下音效, 按下音量)
	else:
		_播放自动加载音效("播放开关音效")


func _播放流(音频流: AudioStream, 音量: float) -> void:
	# 用一次性播放器播放拖入的音频，播完自动释放
	var 播放器 := AudioStreamPlayer.new()
	播放器.stream = 音频流
	播放器.volume_db = 音量
	add_child(播放器)
	播放器.finished.connect(播放器.queue_free)
	播放器.play()


func _播放自动加载音效(方法名: String) -> void:
	var 音效节点 := get_node_or_null("/root/音效")
	if 音效节点 and 音效节点.has_method(方法名):
		音效节点.call(方法名)


func _播放抖动动画(配置: 点击抖动动画) -> void:
	# 绕中心左右旋转抖动，结束时归零；与缩放类动画分别动 rotation/scale，可同时播放
	if _抖动动画 and is_instance_valid(_抖动动画):
		_抖动动画.kill()
	var 弧度角 := deg_to_rad(配置.抖动角度)
	var 单步时长 := 配置.时长 / (配置.抖动次数 * 2.0)
	_抖动动画 = create_tween()
	for i in 配置.抖动次数:
		_抖动动画.tween_property(self, "rotation", 弧度角, 单步时长)
		_抖动动画.tween_property(self, "rotation", -弧度角, 单步时长)
	_抖动动画.tween_property(self, "rotation", 0.0, 单步时长)


func _播放弹跳动画(配置: 点击弹跳动画) -> void:
	# 先放大再弹回；悬停状态下弹回悬停大小
	_终止点击动画()
	# 接管缩放，终止悬停缩放动画避免打架
	_终止动画()
	var 最终大小 := _原始大小 * (_悬停目标倍数() if _悬浮中 else 1.0)
	_点击动画 = create_tween()
	_点击动画.tween_property(self, "scale", _原始大小 * 配置.弹跳放大量, 配置.时长 * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_点击动画.tween_property(self, "scale", 最终大小, 配置.时长 * 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _播放心跳动画(配置: 心跳动画) -> void:
	# 咚-咚 双跳节奏
	_终止点击动画()
	_终止动画()
	var 基准大小 := _原始大小 * (_悬停目标倍数() if _悬浮中 else 1.0)
	_点击动画 = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var 单步 := 配置.时长 / (配置.次数 * 2.0)
	for i in 配置.次数:
		_点击动画.tween_property(self, "scale", 基准大小 * 配置.心跳幅度, 单步)
		_点击动画.tween_property(self, "scale", 基准大小, 单步)


func _播放挤压拉伸动画(配置: 挤压拉伸动画) -> void:
	# 压扁-拉长-复原（卡通质感）
	_终止点击动画()
	_终止动画()
	var 基准大小 := _原始大小 * (_悬停目标倍数() if _悬浮中 else 1.0)
	_点击动画 = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_点击动画.tween_property(self, "scale", 基准大小 * Vector2(1.0 + 配置.挤压量, 1.0 - 配置.挤压量), 配置.时长 * 0.35)
	_点击动画.tween_property(self, "scale", 基准大小 * Vector2(1.0 - 配置.挤压量 * 0.6, 1.0 + 配置.挤压量 * 0.6), 配置.时长 * 0.3)
	_点击动画.tween_property(self, "scale", 基准大小, 配置.时长 * 0.35)


func _播放点击缩放动画(倍数: float) -> void:
	# 点击时以放大/缩小配置播放一次性缩放：弹到倍数再弹回
	_终止点击动画()
	_终止动画()
	var 峰值大小 := _原始大小 * 倍数
	var 最终大小 := _原始大小 * (_悬停目标倍数() if _悬浮中 else 1.0)
	var 时长 := 悬停放大.时长 if 悬停放大 else 0.1
	_点击动画 = create_tween()
	_点击动画.tween_property(self, "scale", 峰值大小, 时长 * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_点击动画.tween_property(self, "scale", 最终大小, 时长 * 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _播放缩放动画(目标大小: Vector2, 时长: float, 缓动: Tween.EaseType, 过渡: Tween.TransitionType) -> void:
	_终止动画()
	_悬浮动画 = create_tween()
	_悬浮动画.set_ease(缓动)
	_悬浮动画.set_trans(过渡)
	_悬浮动画.tween_property(self, "scale", 目标大小, 时长)


func _终止动画() -> void:
	if _悬浮动画 and is_instance_valid(_悬浮动画):
		_悬浮动画.kill()


func _终止点击动画() -> void:
	if _点击动画 and is_instance_valid(_点击动画):
		_点击动画.kill()
