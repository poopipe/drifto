shader_type spatial;

uniform float y_offset = 0.0;
uniform samplerCube texture_sky : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	
	vec3 radial_vector = VERTEX.xyz + vec3(0.0, y_offset, 0.0);
	radial_vector = normalize(radial_vector);
	NORMAL = mix(NORMAL, radial_vector, 0.15);
}

void fragment() {
	
	// view space
	
	vec4 norm = normalize(INV_VIEW_MATRIX * vec4(NORMAL, 0.0));
	vec3 view = normalize(CAMERA_POSITION_WORLD - NODE_POSITION_WORLD);
	vec3 reflection_vector = normalize(-reflect(view, norm.xyz));
	reflection_vector += vec3(0.0, 0.2, 0.0);
	float levels = 4.0;
	reflection_vector = floor(reflection_vector * levels) / levels;
	vec3 col = texture(texture_sky, reflection_vector).xyz ;
	
	//col = floor(col * levels) / levels;
	
	ALBEDO = vec3(col);
	//ALBEDO = norm.xyz;	//NORMAL is converted to worls space
	
	
}

void light() {
	
	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	l = smoothstep(0.0, 0.1	, l);
	DIFFUSE_LIGHT += vec3(l * ATTENUATION) * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));
	//DIFFUSE_LIGHT = vec3(1.0);

}