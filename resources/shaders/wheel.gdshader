shader_type spatial;
#include "res://resources/shaders/cubemap_sample.gdshaderinc"

uniform vec3 basecolor = vec3(0.8, 0.8, 0.8);
uniform float world_light_offset = 0.1;
uniform float world_light_shadow_strength = 0.3;

uniform float reflection_offset = 0.2;

uniform sampler2D texture_basecolor : source_color, filter_linear_mipmap, repeat_enable;
uniform samplerCube texture_sky : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
	
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// consider putting the depth cue into the shaders rather than using fog
	// fog is too soft a falloff and it makes me sad
	
	// world lighting effect - prefer cubemap
	//vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	//float l = clamp(dot(worldNormal, vec3(0.0,1.0,0.0)), 0.0, 1.0);
	//float world_light_offset_end = world_light_offset + 0.01;
	//l = 1.0 - smoothstep(world_light_offset, world_light_offset_end, l) ;
	
	vec3 basecolor_texture = texture(texture_basecolor, UV).xyz;
	
	// view space reflection vector
	vec3 reflection_vector = get_cubemap_uv(INV_VIEW_MATRIX, NORMAL, CAMERA_POSITION_WORLD, NODE_POSITION_WORLD);
	reflection_vector += vec3(0.0, reflection_offset, 0.0);
	float levels = 4.0;
	reflection_vector = floor(reflection_vector * levels) / levels;
	vec3 refl =  clamp(texture(texture_sky, reflection_vector).xxx * 3.0, 0.0, 1.0) ;
	
	ALBEDO = basecolor * basecolor_texture;
	ALBEDO *= refl;
}

void light() {
	vec3 worldLight = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = clamp(dot(worldNormal, worldLight), 0, 1.0);
	float world_light_offset_end = world_light_offset + 0.01;

    DIFFUSE_LIGHT += smoothstep(world_light_offset	, world_light_offset_end, l) * ATTENUATION * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));
}