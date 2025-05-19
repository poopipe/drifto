shader_type spatial;
#include "res://resources/shaders/cubemap_sample.gdshaderinc"
uniform float y_offset = 0.0;
uniform samplerCube texture_sky : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	vec3 radial_vector = VERTEX.xyz + vec3(0.0, y_offset, 0.0);
	radial_vector = normalize(radial_vector);
	NORMAL = mix(NORMAL, radial_vector, 0.15);
}

void fragment() {
	// view space reflection vector
	vec3 reflection_vector = get_cubemap_uv(INV_VIEW_MATRIX, NORMAL, CAMERA_POSITION_WORLD, NODE_POSITION_WORLD);
	reflection_vector += vec3(0.0, 0.2, 0.0);
	float levels = 4.0;
	reflection_vector = floor(reflection_vector * levels) / levels;
	vec3 col = texture(texture_sky, reflection_vector).xxx ;
	ALBEDO = vec3(col);
}

void light() {
	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	l = smoothstep(0.0, 0.1	, l);
	DIFFUSE_LIGHT += vec3(l * ATTENUATION) * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));
}