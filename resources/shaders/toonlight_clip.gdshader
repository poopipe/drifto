// NOTE: Shader automatically converted from Godot Engine 4.4.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_toon, specular_toon;

uniform vec4 basecolor : source_color;
uniform sampler2D texture_alpha : source_color, filter_linear_mipmap, repeat_enable;
uniform float alpha_scissor_threshold : hint_range(0.0, 1.0, 0.001);


void vertex() {

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
	l = smoothstep(0.0, 0.1	, l);
	DIFFUSE_LIGHT += vec3(l * ATTENUATION) * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));

}
