shader_type spatial;

uniform sampler2D texture_basecolor : source_color, filter_linear_mipmap, repeat_enable;
//uniform vec4 basecolor : source_color;
uniform float world_light_strength = 0.2;

void vertex() {
	// Called for every vertex the material is visible on.

}

void fragment() {
	// Called for every pixel the material is visible on.

	// consider putting the depth cue into the shaders rather than using fog
	// fog is too soft a falloff and it makes me sad
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = dot(worldNormal, vec3(0.0,1.0,0.0));

	//l = smoothstep(0.0, 1.0, l) * 2.0 - 1.0;
	l = l * world_light_strength ;
	vec3 basecolor = texture(texture_basecolor, UV).xyz;
	ALBEDO = basecolor.xyz + l; //clamp(basecolor + (l  * world_light_shadow_strength), 0.0, 1.0);

}

void light() {

	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	l = smoothstep(0.0, 0.1	, l);
	DIFFUSE_LIGHT += vec3(l * ATTENUATION);
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));

}