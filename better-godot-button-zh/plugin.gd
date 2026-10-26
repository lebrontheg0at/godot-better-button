@tool
extends EditorPlugin

# 插件入口：注册自定义类型"更好的按钮"
# 节点图标：取编辑器自带的 Button 图标做一份染色副本，与普通按钮区分（不引用任何本地资源文件）

const 图标染色 := Color(1.0, 0.62, 0.25)  # 染色（乘色）；想换颜色改这里

func _enter_tree() -> void:
	add_custom_type("更好的按钮", "Button", preload("better-button.gd"), _生成染色图标("Button", 图标染色))


func _exit_tree() -> void:
	remove_custom_type("更好的按钮")


## 取编辑器内置图标整体乘色（保留 alpha）生成独立纹理；取不到时回落原图标
func _生成染色图标(图标名: String, 染色: Color) -> Texture2D:
	var 原图标: Texture2D = EditorInterface.get_editor_theme().get_icon(图标名, "EditorIcons")
	var 图 := 原图标.get_image()
	if 图 == null:
		return 原图标
	if 图.is_compressed():
		图.decompress()
	图.convert(Image.FORMAT_RGBA8)
	for y in 图.get_height():
		for x in 图.get_width():
			var c := 图.get_pixel(x, y)
			c.r *= 染色.r
			c.g *= 染色.g
			c.b *= 染色.b
			图.set_pixel(x, y, c)
	return ImageTexture.create_from_image(图)
