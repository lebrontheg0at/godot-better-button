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


## Grayscale the built-in editor icon first, then map luminance to the tint color (keep alpha); fall back to the original on failure.
## Desaturation is required: the editor theme recolors built-in icons (a gray-green theme turns a plain multiply into muddy gray-green),
## so normalizing by luminance keeps the icon color stable regardless of the user's theme.
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
			var lum := c.r * 0.299 + c.g * 0.587 + c.b * 0.114
			c.r = tint.r * lum
			c.g = tint.g * lum
			c.b = tint.b * lum
			img.set_pixel(x, y, c)
	return ImageTexture.create_from_image(img)
