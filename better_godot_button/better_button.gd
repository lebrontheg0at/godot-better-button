# uid-marker: en-core
@tool
extends Button
class_name BetterButton

# Multi-texture composite button; every visual is an optional inspector setting.
# Textures: the base 3-state slots (normal/hover/pressed) act as the default first layer;
#   extra layers can be stacked via the texture_layers array, each with its own 3 states.
# Animations: 14 expandable presets, each with its own hover/press/click triggers and parameters.
# Shaders: optional — mouse position is written to a uniform while hovered.
# Sounds: audio slots take priority, otherwise they fall back to the autoload node /root/音效.

# Toggle mode: the button switches on/off on each click
@export var toggle_switch: bool = false:
	set(value):
		toggle_switch = value
		toggle_mode = value

@export_group("Texture")
# Base layer (bottom): drop a normal texture to make it work; hover/pressed are optional
@export var normal_texture: Texture2D = null:
	set(value):
		normal_texture = value
		if is_inside_tree():
			_build_texture_layers()
@export var hover_texture: Texture2D = null:
	set(value):
		hover_texture = value
		if is_inside_tree():
			_build_texture_layers()
@export var pressed_texture: Texture2D = null:
	set(value):
		pressed_texture = value
		if is_inside_tree():
			_build_texture_layers()

# Extra layers stacked above the base; each can choose normal/hover/pressed textures
@export var texture_layers: Array[ButtonTextureLayer] = []:
	set(value):
		texture_layers = value
		if is_inside_tree():
			_build_texture_layers()

@export_group("Shadow")
# Copy the first layer as a darkened, offset shadow — no manual shadow node needed
@export var enable_shadow: bool = false:
	set(value):
		enable_shadow = value
		if is_inside_tree():
			_build_texture_layers()
@export var shadow_offset: Vector2 = Vector2(5, 5):
	set(value):
		shadow_offset = value
		_update_shadow()
@export var shadow_opacity: float = 0.5:
	set(value):
		shadow_opacity = value
		_update_shadow()

@export_group("Animation")
# Each animation expands: tick the trigger (hover/press/click) and tune its parameters
@export var hover_grow: HoverGrowAnimation = null
@export var press_shrink: PressShrinkAnimation = null
@export var click_shake: ClickShakeAnimation = null
@export var click_bounce: ClickBounceAnimation = null
@export var sway_offset: SwayOffsetAnimation = null
@export var hop_offset: HopOffsetAnimation = null
@export var sway_rotation: SwayRotationAnimation = null
@export var vibration: VibrationAnimation = null
@export var blink: BlinkAnimation = null
@export var color_flash: ColorFlashAnimation = null
@export var heartbeat: HeartbeatAnimation = null
@export var squash_stretch: SquashStretchAnimation = null
@export var nod: NodAnimation = null
@export var sink: SinkAnimation = null

@export_group("Text")
# Auto-creates a text label; a same-named Label in the scene is reused instead
@export var text_node_name: String = "Text"
@export var auto_create_text: bool = false:
	set(value):
		auto_create_text = value
		if is_inside_tree():
			_build_text()
@export var text_content: String = "":
	set(value):
		text_content = value
		# Creates the label too when missing — no need to re-toggle auto_create_text
		if is_inside_tree():
			_build_text()
@export var text_font: Font = null:
	set(value):
		text_font = value
		_apply_text_style()
@export var text_size: int = 30:
	set(value):
		text_size = value
		_apply_text_style()
@export var text_color: Color = Color.BLACK:
	set(value):
		text_color = value
		_apply_text_style()
@export var text_outline_color: Color = Color.WHITE:
	set(value):
		text_outline_color = value
		_apply_text_style()
@export var text_outline_size: int = 8:
	set(value):
		text_outline_size = value
		_apply_text_style()

# Text changes color on hover, restores on exit
@export var hover_text_color: Color = Color.BLACK:
	set(value):
		hover_text_color = value
		_update_text_color()

# Label drop shadow
@export var text_shadow_enabled: bool = false:
	set(value):
		text_shadow_enabled = value
		_update_text_shadow()
@export var text_shadow_color: Color = Color(0, 0, 0, 0.588):
	set(value):
		text_shadow_color = value
		_update_text_shadow()
@export var text_shadow_offset: Vector2 = Vector2(3, 3):
	set(value):
		text_shadow_offset = value
		_update_text_shadow()

# Text label moves down while pressed, restores on release
@export var text_offset: Vector2 = Vector2.ZERO:
	set(value):
		text_offset = value
		_update_text_position()
@export var text_press_offset_y: float = 16.0
@export var text_smooth_move: bool = true
@export var text_move_duration: float = 0.05

@export_group("Outline")
# Independent outline; takes priority over preset/custom shaders
@export var enable_outline: bool = false:
	set(value):
		enable_outline = value
		if is_inside_tree():
			_build_texture_layers()
# When checked, the outline is hidden by default and shown only on hover
@export var hover_outline: bool = false:
	set(value):
		hover_outline = value
		_update_outline_visibility()
@export var outline_color: Color = Color.WHITE:
	set(value):
		outline_color = value
		_update_outline_params()
@export var outline_width: float = 2.0:
	set(value):
		outline_width = value
		_update_outline_params()

@export_group("Sound")
# Audio slots take priority; empty slots fall back to the 音效 autoload
@export var hover_sound: AudioStream = null
@export var pressed_sound: AudioStream = null
@export var play_hover_sound: bool = true
@export var play_pressed_sound: bool = true
# The two volumes only apply to dragged-in audio files
@export var hover_volume: float = -10.0
@export var pressed_volume: float = -10.0

@export_group("Shader")
# Built-in preset, selected directly (no manual shader file needed)
@export_enum("None", "3D Preview") var preset_shader: int = 0:
	set(value):
		preset_shader = value
		if is_inside_tree():
			_build_texture_layers()
# Custom shader, used when preset is "None" and outline is disabled
@export var custom_shader: Shader = null:
	set(value):
		custom_shader = value
		if is_inside_tree():
			_build_texture_layers()
@export var mouse_uniform_name: String = "mouse_screen_pos"

var _layer_sprites: Array[Sprite2D] = []
var _shadow_sprite: Sprite2D = null
var _text_label: Label = null
var _text_origin: Vector2 = Vector2.ZERO
var _text_tween: Tween = null
var _base_layer: ButtonTextureLayer = null
var _base_scale: Vector2 = Vector2.ONE
var _hover_tween: Tween = null
var _click_tween: Tween = null
var _shake_tween: Tween = null
var _origin_pos: Vector2 = Vector2.ZERO
var _hovering: bool = false
var _pressing: bool = false
var _pos_tween: Tween = null
var _rot_tween: Tween = null
var _fade_tween: Tween = null

const preset_shader_list: Array[Shader] = [
	null,
	preload("shader/preview_3d.gdshader"),
]
const outline_shader: Shader = preload("shader/outline.gdshader")


func _ready() -> void:
	_base_scale = scale
	_origin_pos = position
	pivot_offset = size / 2.0
	resized.connect(func():
		pivot_offset = size / 2.0
		_reset_text_rect()
		_reset_layer_offset()
	)
	_init_animations()
	_build_texture_layers()
	_build_text()
	if Engine.is_editor_hint():
		return
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or not _hovering:
		return
	var mouse_pos := get_global_mouse_position()
	for sprite in _layer_sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter(mouse_uniform_name, mouse_pos)


func _init_animations() -> void:
	# Fill unset animations with defaults (default: hover grow + press shrink on, rest off)
	if hover_grow == null:
		hover_grow = HoverGrowAnimation.new()
	if press_shrink == null:
		press_shrink = PressShrinkAnimation.new()
	if click_shake == null:
		click_shake = ClickShakeAnimation.new()
	if click_bounce == null:
		click_bounce = ClickBounceAnimation.new()
	if sway_offset == null:
		sway_offset = SwayOffsetAnimation.new()
	if hop_offset == null:
		hop_offset = HopOffsetAnimation.new()
	if sway_rotation == null:
		sway_rotation = SwayRotationAnimation.new()
	if vibration == null:
		vibration = VibrationAnimation.new()
	if blink == null:
		blink = BlinkAnimation.new()
	if color_flash == null:
		color_flash = ColorFlashAnimation.new()
	if heartbeat == null:
		heartbeat = HeartbeatAnimation.new()
	if squash_stretch == null:
		squash_stretch = SquashStretchAnimation.new()
	if nod == null:
		nod = NodAnimation.new()
	if sink == null:
		sink = SinkAnimation.new()


func _hover_target_scale() -> float:
	# Scale base multiplier while hovering
	if hover_grow and hover_grow.play_on_hover:
		return hover_grow.grow_factor
	return 1.0


func _generic_animations() -> Array:
	# The stateful grow/shrink animations are handled separately; the rest go through generic dispatch
	return [click_shake, click_bounce, sway_offset, hop_offset, sway_rotation, vibration, blink, color_flash, heartbeat, squash_stretch, nod, sink]


func _dispatch_generic(trigger_prop: String) -> void:
	for cfg in _generic_animations():
		if cfg and cfg.get(trigger_prop):
			_run_animation(cfg)


func _reset_generic() -> void:
	# On hover exit: tween the properties the generic animations touched back to their base state
	var moved := sway_offset and sway_offset.play_on_hover or hop_offset and hop_offset.play_on_hover \
			or vibration and vibration.play_on_hover or sink and sink.play_on_hover
	var rotated := sway_rotation and sway_rotation.play_on_hover or nod and nod.play_on_hover
	var faded := blink and blink.play_on_hover
	var flashed := color_flash and color_flash.play_on_hover
	if moved:
		if _pos_tween and is_instance_valid(_pos_tween):
			_pos_tween.kill()
		_pos_tween = create_tween()
		_pos_tween.tween_property(self, "position", _origin_pos, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if rotated:
		if _rot_tween and is_instance_valid(_rot_tween):
			_rot_tween.kill()
		_rot_tween = create_tween()
		_rot_tween.tween_property(self, "rotation", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if faded or flashed:
		if _fade_tween and is_instance_valid(_fade_tween):
			_fade_tween.kill()
		_fade_tween = create_tween()
		_fade_tween.tween_property(self, "modulate", Color.WHITE, 0.15)


func _click_takes_scale() -> bool:
	# Click-triggered scale animations take over the scale channel, so release skips restore
	for cfg in [click_bounce, hover_grow, press_shrink, heartbeat, squash_stretch]:
		if cfg and cfg.play_on_click:
			return true
	return false


func _run_animation(cfg) -> void:
	var duration: float = max(0.01, cfg.duration)
	if cfg is ClickShakeAnimation:
		_play_shake(cfg)
	elif cfg is ClickBounceAnimation:
		_play_bounce(cfg)
	elif cfg is HeartbeatAnimation:
		_play_heartbeat(cfg)
	elif cfg is SquashStretchAnimation:
		_play_squash(cfg)
	elif cfg is SwayOffsetAnimation:
		_kill_slot(_pos_tween)
		var base := _origin_pos
		var step: float = duration / (cfg.count * 2.0)
		_pos_tween = create_tween()
		for i in cfg.count:
			_pos_tween.tween_property(self, "position", base + Vector2(cfg.distance, 0), step)
			_pos_tween.tween_property(self, "position", base - Vector2(cfg.distance, 0), step)
		_pos_tween.tween_property(self, "position", base, step)
	elif cfg is HopOffsetAnimation:
		_kill_slot(_pos_tween)
		var base := _origin_pos
		var step: float = duration / (cfg.count * 2.0)
		_pos_tween = create_tween()
		for i in cfg.count:
			_pos_tween.tween_property(self, "position", base + Vector2(0, -cfg.distance), step)
			_pos_tween.tween_property(self, "position", base, step)
	elif cfg is SwayRotationAnimation:
		_kill_slot(_rot_tween)
		var step: float = duration / (cfg.count * 2.0)
		var rad := deg_to_rad(cfg.angle)
		_rot_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		for i in cfg.count:
			_rot_tween.tween_property(self, "rotation", rad, step)
			_rot_tween.tween_property(self, "rotation", -rad, step)
		_rot_tween.tween_property(self, "rotation", 0.0, step)
	elif cfg is VibrationAnimation:
		_kill_slot(_pos_tween)
		var base := _origin_pos
		var step: float = duration / (cfg.count + 1.0)
		_pos_tween = create_tween()
		for i in cfg.count:
			var offset: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * cfg.distance
			_pos_tween.tween_property(self, "position", base + offset, step)
		_pos_tween.tween_property(self, "position", base, step)
	elif cfg is BlinkAnimation:
		_kill_slot(_fade_tween)
		_fade_tween = create_tween()
		for i in cfg.count:
			_fade_tween.tween_property(self, "modulate:a", cfg.min_alpha, duration / (cfg.count * 2.0))
			_fade_tween.tween_property(self, "modulate:a", 1.0, duration / (cfg.count * 2.0))
	elif cfg is ColorFlashAnimation:
		_kill_slot(_fade_tween)
		_fade_tween = create_tween()
		for i in cfg.count:
			_fade_tween.tween_property(self, "modulate", cfg.flash_color, duration / (cfg.count * 2.0))
			_fade_tween.tween_property(self, "modulate", Color.WHITE, duration / (cfg.count * 2.0))
	elif cfg is NodAnimation:
		_kill_slot(_rot_tween)
		var rad := deg_to_rad(cfg.angle)
		_rot_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		_rot_tween.tween_property(self, "rotation", rad, duration * 0.6)
		_rot_tween.tween_property(self, "rotation", 0.0, duration * 0.4)
	elif cfg is SinkAnimation:
		_kill_slot(_pos_tween)
		var base := _origin_pos
		_pos_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_pos_tween.tween_property(self, "position", base + Vector2(0, cfg.distance), duration * 0.5)
		_pos_tween.tween_property(self, "position", base, duration * 0.5)


func _kill_slot(tween: Tween) -> void:
	if tween and is_instance_valid(tween):
		tween.kill()


func _current_layers() -> Array:
	# Base layer is the default first layer; texture_layers stack on top
	var list := []
	if _base_layer:
		list.append(_base_layer)
	list.append_array(texture_layers)
	return list


func _build_texture_layers() -> void:
	# Remove last auto-created nodes; same-named manual nodes in the scene are reused
	for child in get_children(true):
		if child is Sprite2D and child.has_meta("plugin_created"):
			remove_child(child)
			child.free()
	_layer_sprites.clear()
	_base_layer = null
	if normal_texture:
		_base_layer = ButtonTextureLayer.new()
		_base_layer.name = "Normal"
		_base_layer.normal_texture = normal_texture
		_base_layer.hover_texture = hover_texture
		_base_layer.pressed_texture = pressed_texture
		# Texture is centered on the button by default
		if size != Vector2.ZERO:
			_base_layer.offset = size / 2.0
	for cfg in _current_layers():
		if cfg == null:
			continue
		var sprite := _find_layer(cfg.name)
		if sprite == null:
			sprite = Sprite2D.new()
			sprite.name = cfg.name
			sprite.set_meta("plugin_created", true)
			# Internal node: hidden from the scene dock, fully managed by the plugin
			add_child(sprite, false, Node.INTERNAL_MODE_BACK)

		_layer_sprites.append(sprite)
	# Reconnect signals each build so newly added layers refresh live
	for cfg in texture_layers:
		if cfg and not cfg.changed.is_connected(_refresh_layers):
			cfg.changed.connect(_refresh_layers)
	_refresh_layers()
	_build_shadow()


func _build_shadow() -> void:
	_shadow_sprite = null
	if not enable_shadow or _layer_sprites.is_empty():
		return
	var sprite := Sprite2D.new()
	sprite.name = "QuickShadow"
	sprite.set_meta("plugin_created", true)
	# Internal node + FRONT: drawn first, behind all layers
	add_child(sprite, false, Node.INTERNAL_MODE_FRONT)

	_shadow_sprite = sprite
	_update_shadow()
	# Sync the shadow texture on first build (later handled by _refresh_textures following the first layer)
	if not _layer_sprites.is_empty():
		_shadow_sprite.texture = _layer_sprites[0].texture


func _update_shadow() -> void:
	var list := _current_layers()
	if _shadow_sprite == null or not is_instance_valid(_shadow_sprite) or list.is_empty():
		return
	var cfg: ButtonTextureLayer = list[0]
	_shadow_sprite.modulate = Color(0.0, 0.0, 0.0, shadow_opacity)
	_shadow_sprite.scale = cfg.scale
	_shadow_sprite.position = cfg.offset + shadow_offset


func _reset_layer_offset() -> void:
	# The base layer is centered on the button; size may still be 0 during _ready, so the offset
	# baked from a zero rect has to be recomputed whenever the size changes
	if _base_layer == null or size == Vector2.ZERO:
		return
	_base_layer.offset = size / 2.0
	_refresh_layers()
	_update_shadow()


func _find_layer(name: String) -> Sprite2D:
	for child in get_children(true):
		if child is Sprite2D and child.name == name and not child.has_meta("plugin_created"):
			return child
	return null


func _build_text() -> void:
	# Reuse a same-named Label in the scene; otherwise create one if auto_create_text is on
	_text_label = null
	for child in get_children(true):
		if child is Label and child.name == text_node_name:
			_text_label = child
			break
	if _text_label == null and auto_create_text and not text_content.is_empty():
		var label := Label.new()
		label.name = text_node_name
		label.set_meta("plugin_created", true)
		add_child(label, false, Node.INTERNAL_MODE_BACK)

		_text_label = label
		_apply_text_style()
	if _text_label:
		_reset_text_rect()


func _reset_text_rect() -> void:
	# Fill the button and center the text; reused scene nodes are normalized the same way
	# The offsets must be zeroed explicitly: the button may still be 0x0 during _ready, and when
	# the parent is smaller than the Label's minimum size Godot bakes that minimum into the
	# offsets and never recovers, so any size change has to redo this
	if _text_label == null or not is_instance_valid(_text_label):
		return
	_text_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_text_label.offset_left = 0.0
	_text_label.offset_top = 0.0
	_text_label.offset_right = 0.0
	_text_label.offset_bottom = 0.0
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_text_label.z_index = 1
	_text_origin = _text_label.position
	_update_text_position()


func _update_text_position() -> void:
	if _text_label == null or not is_instance_valid(_text_label):
		return
	if _text_tween and is_instance_valid(_text_tween):
		_text_tween.kill()
	_text_label.position = _text_origin + text_offset


func _update_text_shadow() -> void:
	if _text_label == null or not is_instance_valid(_text_label):
		return
	if text_shadow_enabled:
		_text_label.add_theme_color_override("font_shadow_color", text_shadow_color)
		_text_label.add_theme_constant_override("shadow_offset_x", int(text_shadow_offset.x))
		_text_label.add_theme_constant_override("shadow_offset_y", int(text_shadow_offset.y))
	else:
		# Transparent shadow color clears the shadow when disabled
		_text_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))


func _update_text_color() -> void:
	if _text_label == null or not is_instance_valid(_text_label):
		return
	_text_label.add_theme_color_override("font_color", hover_text_color if _hovering else text_color)


func _apply_text_style() -> void:
	if _text_label == null or not is_instance_valid(_text_label):
		return
	_text_label.text = text_content
	if text_font:
		_text_label.add_theme_font_override("font", text_font)
	_text_label.add_theme_font_size_override("font_size", text_size)
	_update_text_color()
	_text_label.add_theme_color_override("font_outline_color", text_outline_color)
	_text_label.add_theme_constant_override("outline_size", text_outline_size)
	_update_text_shadow()


func _current_shader() -> Shader:
	if enable_outline:
		return outline_shader
	if preset_shader > 0:
		return preset_shader_list[preset_shader]
	return custom_shader


func _update_outline_visibility() -> void:
	for sprite in _layer_sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("show_outline", 1.0 if (not hover_outline or _hovering) else 0.0)


func _update_outline_params() -> void:
	for sprite in _layer_sprites:
		if sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("outline_color", outline_color)
			sprite.material.set_shader_parameter("outline_width", outline_width)


func _refresh_layers() -> void:
	var list := _current_layers()
	for i in _layer_sprites.size():
		if i >= list.size():
			break
		var cfg: ButtonTextureLayer = list[i]
		var sprite := _layer_sprites[i]
		sprite.position = cfg.offset
		sprite.scale = cfg.scale
		sprite.modulate = cfg.color
		var shader := _current_shader()
		if shader:
			var material := ShaderMaterial.new()
			material.shader = shader
			material.set_shader_parameter("outline_color", outline_color)
			material.set_shader_parameter("outline_width", outline_width)
			material.set_shader_parameter("show_outline", 1.0 if (not hover_outline or _hovering) else 0.0)
			sprite.material = material
	_refresh_textures()
	_update_shadow()


func _refresh_textures() -> void:
	var list := _current_layers()
	for i in _layer_sprites.size():
		if i >= list.size():
			break
		var cfg: ButtonTextureLayer = list[i]
		var target := cfg.normal_texture
		if _pressing and cfg.pressed_texture:
			target = cfg.pressed_texture
		elif _hovering and cfg.hover_texture:
			target = cfg.hover_texture
		_layer_sprites[i].texture = target
	# Shadow follows the first layer so it stays in sync on hover/press switching
	if _shadow_sprite and is_instance_valid(_shadow_sprite) and not _layer_sprites.is_empty():
		_shadow_sprite.texture = _layer_sprites[0].texture


func _on_mouse_entered() -> void:
	if disabled:
		return
	_hovering = true
	_refresh_textures()
	_update_outline_visibility()
	_play_hover_sound()
	_update_text_color()
	# Hover-triggered animations: stateful scale + generic dispatch
	if hover_grow and hover_grow.play_on_hover:
		_play_scale_tween(_base_scale * hover_grow.grow_factor, hover_grow.duration, hover_grow.easing, hover_grow.transition)
	if press_shrink and press_shrink.play_on_hover:
		_play_scale_tween(_base_scale * press_shrink.shrink_factor, press_shrink.duration, press_shrink.easing, press_shrink.transition)
	if click_shake and click_shake.play_on_hover:
		_play_shake(click_shake)
	_dispatch_generic("play_on_hover")


func _on_mouse_exited() -> void:
	_hovering = false
	# Restore the text even when exiting while pressed (matches the original sort-switch behavior)
	_play_text_move(false)
	_update_outline_visibility()
	_update_text_color()
	if _pressing:
		return
	_refresh_textures()
	# Restore the hover scale
	if hover_grow and hover_grow.play_on_hover:
		_play_scale_tween(_base_scale, hover_grow.duration, hover_grow.easing, hover_grow.transition)
	elif press_shrink and press_shrink.play_on_hover:
		_play_scale_tween(_base_scale, press_shrink.duration, press_shrink.easing, press_shrink.transition)
	_reset_generic()


func _on_button_down() -> void:
	_pressing = true
	_refresh_textures()
	_play_text_move(true)
	# Press-triggered animations
	if press_shrink and press_shrink.play_on_press:
		_play_scale_tween(_base_scale * press_shrink.shrink_factor, press_shrink.duration, press_shrink.easing, press_shrink.transition)
	if hover_grow and hover_grow.play_on_press:
		_play_scale_tween(_base_scale * hover_grow.grow_factor, hover_grow.duration, hover_grow.easing, hover_grow.transition)
	if click_shake and click_shake.play_on_press:
		_play_shake(click_shake)
	if click_bounce and click_bounce.play_on_press:
		_play_bounce(click_bounce)
	_dispatch_generic("play_on_press")


func _on_button_up() -> void:
	_pressing = false
	_refresh_textures()
	_play_text_move(false)
	# Click-triggered scale animations take over the scale channel, so release skips restore
	if _click_takes_scale():
		return
	# After a press-scale, restore to hover size when hovering, else to base size
	var was_scaled := (press_shrink and press_shrink.play_on_press) or (hover_grow and hover_grow.play_on_press)
	if was_scaled:
		_play_scale_tween(_base_scale * _hover_target_scale(), hover_grow.duration if hover_grow else 0.1,
				hover_grow.easing if hover_grow else Tween.EASE_OUT, hover_grow.transition if hover_grow else Tween.TRANS_BACK)


func _on_pressed() -> void:
	_play_pressed_sound()
	# Click-triggered animations: stateful scale + generic dispatch
	if hover_grow and hover_grow.play_on_click:
		_play_click_scale(hover_grow.grow_factor)
	if press_shrink and press_shrink.play_on_click:
		_play_click_scale(press_shrink.shrink_factor)
	_dispatch_generic("play_on_click")


func _play_text_move(down: bool) -> void:
	if _text_label == null or not is_instance_valid(_text_label):
		return
	if _text_tween and is_instance_valid(_text_tween):
		_text_tween.kill()
	var base := _text_origin + text_offset
	var target_y := base.y + (text_press_offset_y if down else 0.0)
	if text_smooth_move:
		_text_tween = create_tween()
		_text_tween.set_ease(Tween.EASE_OUT)
		_text_tween.set_trans(Tween.TRANS_CUBIC)
		_text_tween.tween_property(_text_label, "position:y", target_y, text_move_duration)
	else:
		# Instant move, not smooth
		_text_label.position = Vector2(base.x, target_y)


func _play_hover_sound() -> void:
	if not play_hover_sound:
		return
	if hover_sound:
		_play_stream(hover_sound, hover_volume)
	else:
		_play_autoload_sound("播放选中音效")


func _play_pressed_sound() -> void:
	if not play_pressed_sound:
		return
	if pressed_sound:
		_play_stream(pressed_sound, pressed_volume)
	else:
		_play_autoload_sound("播放开关音效")


func _play_stream(stream: AudioStream, volume: float) -> void:
	# Plays the dragged-in audio with a one-shot player that frees itself when done
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _play_autoload_sound(method: String) -> void:
	var node := get_node_or_null("/root/音效")
	if node and node.has_method(method):
		node.call(method)


func _play_shake(cfg: ClickShakeAnimation) -> void:
	# Rotates left/right around center, ends at zero; runs on its own rotation channel
	if _shake_tween and is_instance_valid(_shake_tween):
		_shake_tween.kill()
	var rad := deg_to_rad(cfg.shake_angle)
	var step := cfg.duration / (cfg.shake_count * 2.0)
	_shake_tween = create_tween()
	for i in cfg.shake_count:
		_shake_tween.tween_property(self, "rotation", rad, step)
		_shake_tween.tween_property(self, "rotation", -rad, step)
	_shake_tween.tween_property(self, "rotation", 0.0, step)


func _play_bounce(cfg: ClickBounceAnimation) -> void:
	# Pops up then springs back; springs back to hover size when hovering
	_kill_click_tween()
	# Take over the scale channel: kill the hover scale tween to avoid conflict
	_kill_hover_tween()
	var final_size := _base_scale * (_hover_target_scale() if _hovering else 1.0)
	_click_tween = create_tween()
	_click_tween.tween_property(self, "scale", _base_scale * cfg.bounce_scale, cfg.duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_click_tween.tween_property(self, "scale", final_size, cfg.duration * 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _play_heartbeat(cfg: HeartbeatAnimation) -> void:
	# Dum-dum double pulse
	_kill_click_tween()
	_kill_hover_tween()
	var base_size := _base_scale * (_hover_target_scale() if _hovering else 1.0)
	_click_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	var step := cfg.duration / (cfg.count * 2.0)
	for i in cfg.count:
		_click_tween.tween_property(self, "scale", base_size * cfg.pulse_factor, step)
		_click_tween.tween_property(self, "scale", base_size, step)


func _play_squash(cfg: SquashStretchAnimation) -> void:
	# Flatten - stretch - restore (cartoon feel)
	_kill_click_tween()
	_kill_hover_tween()
	var base_size := _base_scale * (_hover_target_scale() if _hovering else 1.0)
	_click_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_click_tween.tween_property(self, "scale", base_size * Vector2(1.0 + cfg.squash_amount, 1.0 - cfg.squash_amount), cfg.duration * 0.35)
	_click_tween.tween_property(self, "scale", base_size * Vector2(1.0 - cfg.squash_amount * 0.6, 1.0 + cfg.squash_amount * 0.6), cfg.duration * 0.3)
	_click_tween.tween_property(self, "scale", base_size, cfg.duration * 0.35)


func _play_click_scale(factor: float) -> void:
	# One-shot scale using the grow/shrink factor: pop to the factor, then spring back
	_kill_click_tween()
	_kill_hover_tween()
	var peak := _base_scale * factor
	var final_size := _base_scale * (_hover_target_scale() if _hovering else 1.0)
	var duration := hover_grow.duration if hover_grow else 0.1
	_click_tween = create_tween()
	_click_tween.tween_property(self, "scale", peak, duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_click_tween.tween_property(self, "scale", final_size, duration * 0.7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func _play_scale_tween(target: Vector2, duration: float, easing: Tween.EaseType, transition: Tween.TransitionType) -> void:
	_kill_hover_tween()
	_hover_tween = create_tween()
	_hover_tween.set_ease(easing)
	_hover_tween.set_trans(transition)
	_hover_tween.tween_property(self, "scale", target, duration)


func _kill_hover_tween() -> void:
	if _hover_tween and is_instance_valid(_hover_tween):
		_hover_tween.kill()


func _kill_click_tween() -> void:
	if _click_tween and is_instance_valid(_click_tween):
		_click_tween.kill()
