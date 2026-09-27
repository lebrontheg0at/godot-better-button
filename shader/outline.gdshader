shader_type canvas_item;

// 纹理描边：沿纹理透明边缘生成一圈描边
// 描边宽度以纹理像素为单位，会随精灵缩放

uniform vec4 描边颜色 : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float 描边宽度 : hint_range(0.0, 16.0) = 2.0;
// 悬停描边用：0 隐藏描边，1 显示
uniform float 显示描边 : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 原色 = texture(TEXTURE, UV);
	float 描边透明度 = 0.0;
	if (描边宽度 > 0.0) {
		for (float 角度 = 0.0; 角度 < 360.0; 角度 += 22.5) {
			vec2 采样偏移 = vec2(cos(角度 * PI / 180.0), sin(角度 * PI / 180.0)) * 描边宽度 * TEXTURE_PIXEL_SIZE;
			描边透明度 = max(描边透明度, texture(TEXTURE, UV + 采样偏移).a);
		}
	}
	vec4 描边色 = vec4(描边颜色.rgb, 描边颜色.a * 描边透明度 * 显示描边);
	// 原图不透明处显示原图，边缘处与描边混合
	COLOR = mix(描边色, 原色, 原色.a);
}
