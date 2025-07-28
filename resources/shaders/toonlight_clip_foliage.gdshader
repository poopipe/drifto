shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;

uniform vec4 basecolor : source_color;
uniform sampler2D texture_alpha : source_color, filter_linear_mipmap, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001);

uniform float sway_speed = 3.0;
uniform float sway_strength = 0.2;
uniform float sway_phase_len = 8.0;

void vertex() {
	float strength = COLOR.r * sway_strength;
    VERTEX.x += sin(VERTEX.x * sway_phase_len * 1.123 + TIME * sway_speed) * strength;
    VERTEX.y += sin(VERTEX.y * sway_phase_len + TIME * sway_speed * 1.12412) * strength;
    VERTEX.z += sin(VERTEX.z * sway_phase_len * 0.9123 + TIME * sway_speed * 1.3123) * strength;
}

void fragment() {
	vec2 pos = UV;

	vec4 alpha = texture(texture_alpha, pos);
	ALBEDO = basecolor.xyz;
	vec3 fn = NORMAL;
	vec3 bn = -NORMAL;
	vec3 n = fn;
	if(!FRONT_FACING){
		n = bn;
	}

	NORMAL = n;
	ALPHA *= alpha.w;
	ALPHA_SCISSOR_THRESHOLD = alpha_scissor_threshold;
	//ALBEDO = vec3(sign(NORMAL.z));
}
void light() {


	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	l = smoothstep(0.1	, 0.1	, l);
	DIFFUSE_LIGHT += vec3(l * ATTENUATION) * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));

}
