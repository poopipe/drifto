shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_linear_mipmap;
//uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
//uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D noise: repeat_enable;

uniform float coverage = 0.0	;

void vertex(){
	POSITION = vec4(VERTEX.xy * 2.0, 1.0, 1.0);
}

vec2 cartesian_to_polar(vec2 uv, vec2 center){
	vec2 d = uv-center;
	float r = length(d) * 2.0;
	float t = atan(d.y, d.x) * 1.0/(PI * 2.0);
	return vec2(r, t);
}

float effect_mask(float posx, float cov, float offset, float aspect){
	// effect masking
	// apply an offset so we get a peephole
	float c = cov + offset;
	float d = 1.0 - (posx / 4.0 * aspect + c);
	return clamp(d, 0.0, 1.0);
	
}

void fragment() {
	// sort out UVs
	float ratio = 1.0 / ( VIEWPORT_SIZE.x / VIEWPORT_SIZE.y);
	vec2 pos = SCREEN_UV * 2.0 - 1.0;
	pos = vec2(pos.x / ratio , pos.y  );
	pos = cartesian_to_polar(pos, vec2(0.0));
	
	float mask = effect_mask(pos.x, coverage * 0.1, 0.5, ratio);
	mask = smoothstep(0.0, 0.2, mask);
	mask =  mask;
	
	vec3 screen_texture = texture(SCREEN_TEXTURE, SCREEN_UV).xyz;
	//vec3 lines = vec3(d); // vec3(rings * (1.0 - d));
	ALBEDO = screen_texture * vec3(mask) ;


}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
