shader_type canvas_item;

// Texture outline: samples around the transparent edge to draw a silhouette outline.
// Width is in texture pixels and scales with the sprite.

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 16.0) = 2.0;
// Used for hover-only mode: 0 hides the outline, 1 shows it
uniform float show_outline : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	float outline_alpha = 0.0;
	if (outline_width > 0.0) {
		for (float angle = 0.0; angle < 360.0; angle += 22.5) {
			vec2 sample_offset = vec2(cos(angle * PI / 180.0), sin(angle * PI / 180.0)) * outline_width * TEXTURE_PIXEL_SIZE;
			outline_alpha = max(outline_alpha, texture(TEXTURE, UV + sample_offset).a);
		}
	}
	vec4 outline_result = vec4(outline_color.rgb, outline_color.a * outline_alpha * show_outline);
	// Opaque area shows the base texture; the edge blends with the outline
	COLOR = mix(outline_result, base_color, base_color.a);
}
