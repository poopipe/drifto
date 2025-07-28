shader_type spatial;
render_mode cull_disabled, unshaded, blend_add;
#include "res://resources/shaders/uv_functions.gdshaderinc"

// why no scales?

//uniform vec3 uv1_scale = vec3(1.0);
//uniform vec3 uv1_offset = vec3(1.0);
uniform float billboard_scale = 1.0;
uniform float intensity = 1.0;
//uniform sampler2D mask_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D noise: repeat_enable;

uniform float v_curve = 1.0;
uniform float v_offset1 = 0.0;
uniform float v_offset2 = 0.0;
void vertex() {
	UV = UV ;// * uv1_scale.xy + uv1_offset.xy; // No idea why there's a scale there
	// face camera
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(
			MAIN_CAM_INV_VIEW_MATRIX[0],
			MAIN_CAM_INV_VIEW_MATRIX[2],
			MAIN_CAM_INV_VIEW_MATRIX[1],
			MODEL_MATRIX[3]);
	// scale
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(
		vec4(length(MODEL_MATRIX[0].xyz * billboard_scale), 0.0, 0.0, 0.0),
		vec4(0.0, length(MODEL_MATRIX[1].xyz * billboard_scale), 0.0, 0.0),
		vec4(0.0, 0.0, length(MODEL_MATRIX[2].xyz* billboard_scale), 0.0),
		vec4(0.0, 0.1, 0.0, 1.0));

	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);

}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	uv = polar_coords(UV, vec2(0.495,0.495));
	vec2 uv2 = polar_coords(UV, vec2(0.505,0.505));
	
	uv *= vec2(1.0, 3.0);
	uv2 *= vec2(1.0, 3.0);
	
	uv = vec2(uv.x, pow(uv.y, v_curve));
	uv2 = vec2(uv2.x, pow(uv2.y, v_curve));
	
	
	float v_offset_sin =  sin(TIME * 0.01);
	
	
	float lines = texture(noise, vec2(v_offset1 + v_offset_sin, uv.y * 1.5)).x * 2.0-1.0 - (uv.y * 0.2);
	float lines2 = texture(noise, vec2(v_offset2 + v_offset_sin, uv2.y * 1.5)).x * 2.0-1.0 - (uv2.y * 0.2);
	
	float msk = length(UV - vec2(0.5,0.5)) * 2.0;
	msk = clamp(msk, 0.0, 1.0);
	msk = pow(1.0-msk, 2.0) ;
	
	lines =  (lines + lines2) * msk;
	lines = clamp(lines, 0.0, 1.0);
	
	lines = smoothstep(0.0, 0.2, lines) ;
	
	ALBEDO = vec3(lines) * intensity;
	
	
	// use texture from streetlight
	//ALBEDO = texture(mask_texture,UV).xyz * intensity;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
