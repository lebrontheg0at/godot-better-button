# uid-marker: en-plugin
@tool
extends EditorPlugin

# Plugin entry: registers the "Better Button" custom type.
# Node icon: tinted copy of the editor's built-in Button icon (no local asset files referenced).

const ICON_TINT := Color(1.0, 0.62, 0.25)  # multiply tint; change here

func _enter_tree() -> void:
	add_custom_type("Better Button", "Button", preload("better-button.gd"), _make_tinted_icon("Button", ICON_TINT))


func _exit_tree() -> void:
	remove_custom_type("Better Button")


## Tint the built-in editor icon (multiply color, keep alpha) into a standalone texture; fall back to the original on failure
func _make_tinted_icon(icon_name: String, tint: Color) -> Texture2D:
	var base_icon: Texture2D = EditorInterface.get_editor_theme().get_icon(icon_name, "EditorIcons")
	var img := base_icon.get_image()
	if img == null:
		return base_icon
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			c.r *= tint.r
			c.g *= tint.g
			c.b *= tint.b
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)
