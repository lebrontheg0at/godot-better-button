shader_type canvas_item;

// 纹理描边：沿纹理透明边缘生成一圈描边
// 顶点外扩 outline_width 像素，让描边能画到纹理四边形之外（否则贴边的尖角处没有描边空间）
// 注意：着色器语言不支持中文标识符，uniform 与变量必须用 ASCII 命名

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float outline_width : hint_range(0.0, 16.0) = 2.0;
// 悬停描边用：0 隐藏描边，1 显示
uniform float show_outline : hint_range(0.0, 1.0) = 1.0;

void vertex() {
	// 按 UV 象限把四个顶点向外推，UV 插值随之延伸到 [0,1] 之外
	VERTEX += sign(UV - vec2(0.5)) * outline_width;
}

void fragment() {
	// 钳制采样：四边形之外的像素取最近的边缘纹素
	vec2 uv = clamp(UV, vec2(0.0), vec2(1.0));
	vec4 base_color = texture(TEXTURE, uv);
	float outline_alpha = 0.0;
	if (outline_width > 0.0) {
		for (float angle = 0.0; angle < 360.0; angle += 22.5) {
			vec2 sample_offset = vec2(cos(angle * PI / 180.0), sin(angle * PI / 180.0)) * outline_width * TEXTURE_PIXEL_SIZE;
			outline_alpha = max(outline_alpha, texture(TEXTURE, clamp(UV + sample_offset, vec2(0.0), vec2(1.0))).a);
		}
	}
	// 仅当像素落在原四边形内才显示原图；四边形外只显示描边
	float inside = step(0.0, UV.x) * step(UV.x, 1.0) * step(0.0, UV.y) * step(UV.y, 1.0);
	vec4 outline_result = vec4(outline_color.rgb, outline_color.a * outline_alpha * show_outline);
	COLOR = mix(outline_result, base_color, base_color.a * inside);
}
