shader_type spatial;

uniform vec3 basecolor = vec3(0.8, 0.8, 0.8);
uniform float world_light_offset = 0.1;
uniform float world_light_shadow_strength = 0.3;

uniform sampler2D texture_basecolor : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// consider putting the depth cue into the shaders rather than using fog
	// fog is too soft a falloff and it makes me sad
	
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = clamp(dot(worldNormal, vec3(0.0,1.0,0.0)), 0.0, 1.0);
	float world_light_offset_end = world_light_offset + 0.01;
	l = 1.0 - smoothstep(world_light_offset, world_light_offset_end, l) ;
	vec3 basecolor_texture = texture(texture_basecolor, UV).xyz;
	ALBEDO = basecolor * basecolor_texture - (l * world_light_shadow_strength);
}

void light() {
	vec3 worldLight = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = clamp(dot(worldNormal, worldLight), 0, 1.0);
	float world_light_offset_end = world_light_offset + 0.01;

    DIFFUSE_LIGHT += smoothstep(world_light_offset	, world_light_offset_end, l) * ATTENUATION * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));
}