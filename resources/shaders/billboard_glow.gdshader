shader_type spatial;
render_mode cull_disabled, blend_add, unshaded;
// why no scales?

uniform vec3 uv1_scale = vec3(1.0);
uniform vec3 uv1_offset = vec3(1.0);
uniform float billboard_scale = 1.0;
uniform float intensity = 1.0;
uniform sampler2D mask_texture : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;

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
		vec4(0.0, 0.5, 0.0, 1.0));
	

	
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	
}

void fragment() {
	// use texture from streetlight
	ALBEDO = texture(mask_texture, UV).xyz * intensity;
	
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
