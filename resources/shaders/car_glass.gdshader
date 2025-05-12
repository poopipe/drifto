shader_type spatial;
uniform float horizon_offset = 0.0;
uniform float y_offset = 0.0;
uniform samplerCube texture_sky : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	vec3 radial_vector = VERTEX.xyz + vec3(0.0, y_offset, 0.0);
	radial_vector = normalize(radial_vector);
	NORMAL = radial_vector;
}

void fragment() {
	
	// view space
	
	vec4 norm = normalize(INV_VIEW_MATRIX * vec4(NORMAL, 0.0));
	vec3 view = normalize(CAMERA_POSITION_WORLD - NODE_POSITION_WORLD);
	vec3 reflection_vector = normalize(-reflect(view, norm.xyz));


	vec3 col = texture(texture_sky, reflection_vector).xyz;
	
	ALBEDO = vec3(col);
	//ALBEDO = NORMAL;
	
	
}

void light() {
	
	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	l = smoothstep(0.0, 0.1	, l);
	DIFFUSE_LIGHT += vec3(l * ATTENUATION) * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));
	//DIFFUSE_LIGHT = vec3(1.0);

}