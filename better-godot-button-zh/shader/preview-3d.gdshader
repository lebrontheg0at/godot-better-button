shader_type canvas_item;

//3D效果调控开关
uniform bool enable_3d_preview = true;
uniform float force = 0.5;

//相机FOV
uniform float fov : hint_range(1, 179) = 90;
uniform bool cull_back = true;
uniform float y_rot : hint_range(-180, 180) = 0.0;
uniform float x_rot : hint_range(-180, 180) = 0.0;

uniform float inset : hint_range(0, 1) = 0.0;


//卡片旋转角度
uniform float rotation : hint_range(-10.0, 10.0, 0.1) = 0.0;

//限制鼠标偏移的最大值
uniform float max_force : hint_range(0.1, 5.0, 0.1) = 1.0;

uniform vec2 mouse_screen_pos = vec2(0.0, 0.0);

//3D效果参数
varying flat vec2 o;
varying vec3 p;
varying vec2 transformed_world_to_canvas_coordinates;
varying flat vec2 pivot;
varying flat vec2 region_rate;
varying flat mat3 inv_rot_mat;

//旋转函数
vec2 rotate(vec2 uv, vec2 pivot_r, float angle) {
    mat2 rotation_mat = mat2(
        vec2(cos(angle), -sin(angle)),
        vec2(sin(angle), cos(angle))
    );
    uv -= pivot_r;
    uv = uv * rotation_mat;
    uv += pivot_r;
    return uv;
}

void vertex() {
    //初始化
    pivot = vec2(0.0, 0.0);
    region_rate = vec2(1.0, 1.0);
    
    //开关
    if (enable_3d_preview) {
        vec2 my_region_rate = abs(VERTEX) * 2.0;
        region_rate = TEXTURE_PIXEL_SIZE * my_region_rate;

        if (VERTEX_ID == 0) pivot = UV;
        if (VERTEX_ID == 1) pivot = UV - vec2(0.0, region_rate.y);
        if (VERTEX_ID == 2) pivot = UV - vec2(region_rate.x, region_rate.y);
        if (VERTEX_ID == 3) pivot = UV - vec2(region_rate.x, 0.0);
        
        //校准
        if (pivot.x < 0.0 || pivot.y < 0.0 || pivot.x > 1.0 || pivot.y > 1.0) {
            pivot = vec2(0.5, 0.5) - (region_rate / 2.0);
        }

        transformed_world_to_canvas_coordinates =
            (inverse(MODEL_MATRIX) * vec4(mouse_screen_pos, 0.0, 1.0)).xy;

        vec2 raw_force = (transformed_world_to_canvas_coordinates) /
                         length(region_rate / TEXTURE_PIXEL_SIZE);

        raw_force = clamp(raw_force, vec2(-max_force), vec2(max_force));
        
        //强度
        vec2 mouse_force = force * raw_force;

        float sin_b = sin(y_rot / 180.0 * PI + mouse_force.x);
        float cos_b = cos(y_rot / 180.0 * PI + mouse_force.x);
        float sin_c = sin(x_rot / 180.0 * PI - mouse_force.y);
        float cos_c = cos(x_rot / 180.0 * PI - mouse_force.y);

        inv_rot_mat[0][0] = cos_b;
        inv_rot_mat[0][1] = 0.0;
        inv_rot_mat[0][2] = -sin_b;

        inv_rot_mat[1][0] = sin_b * sin_c;
        inv_rot_mat[1][1] = cos_c;
        inv_rot_mat[1][2] = cos_b * sin_c;

        inv_rot_mat[2][0] = sin_b * cos_c;
        inv_rot_mat[2][1] = -sin_c;
        inv_rot_mat[2][2] = cos_b * cos_c;

        vec2 uv = (UV - pivot) / region_rate;
        float t = tan(fov / 360.0 * PI);

        VERTEX += (uv - 0.5) * 1.0 * my_region_rate * t * (1.0 - inset);
    }
}

void fragment() {
    if (enable_3d_preview) {
        vec2 uv = (UV - pivot) / region_rate;
        float t = tan(fov / 360.0 * PI);

        p = inv_rot_mat * vec3((uv - 0.5), 0.5 / t);
        float v = (0.5 / t) + 0.5;
        p.xy *= v * inv_rot_mat[2].z;
        o = v * inv_rot_mat[2].xy;

        if (cull_back && p.z <= 0.0) discard;

        uv = (p.xy / p.z).xy - o;
        uv += 0.5;

        vec2 texture_center = vec2(0.5, 0.5);
        vec2 uv_offset = texture_center - (pivot + region_rate / 2.0);
        uv += uv_offset * region_rate;

        float asp = (region_rate / TEXTURE_PIXEL_SIZE).y /
                    (region_rate / TEXTURE_PIXEL_SIZE).x;
        uv.y *= asp;

        uv = rotate(uv, vec2(0.5, 0.5), rotation);

        uv.y /= asp;

        if (uv.x > 1.0 || uv.x < 0.0) discard;
        if (uv.y > 1.0 || uv.y < 0.0) discard;

        //纹理采样对齐
        uv = clamp(pivot + uv * region_rate, vec2(0.0), vec2(1.0));
        COLOR = texture(TEXTURE, uv);
    } else {
        //2D效果
        vec2 raw_uv = clamp(UV, vec2(0.0), vec2(1.0));
        COLOR = texture(TEXTURE, raw_uv);
    }
}