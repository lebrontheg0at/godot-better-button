shader_type canvas_item;

// 纹理描边：沿纹理透明边缘生成一圈描边
// 注意：着色器语言不支持中文标识符，uniform 与变量必须用 ASCII 命名

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 16.0) = 2.0;
// 悬停描边用：0 隐藏描边，1 显示
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
	// 原图不透明处显示原图，边缘处与描边混合
	COLOR = mix(outline_result, base_color, base_color.a);
}
