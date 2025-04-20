shader_type spatial;
//render_mode unshaded;
uniform float world_light_offset = 0.1;
//uniform float world_light_shadow_strength = 0.3;
uniform vec3 basecolor = vec3(0.2, 0.2, 0.2);
uniform float speed = 0.0;
uniform sampler2D noise: repeat_enable;

void vertex() {
}

void fragment() {
	vec2 pos = fract(UV);

	float bands = step(0.5	, pos.x);
	bands = bands * 0.25+0.5;

	float lines = fract(pos.y * 8.0);
	
	lines = abs(lines * 2.0 - 1.0);
	float center = 1.0 - step(0.025, lines);
	float sides = step(0.875, lines);
	sides = sides - step(0.9, lines);

	vec2 speedlines_pos = fract(UV);
	speedlines_pos *= vec2(1.0,64.0);
	float speedlines = texture(noise, speedlines_pos).x;
	float speedline_threshold = 0.5;
	speedlines = smoothstep(speedline_threshold, speedline_threshold + 0.1, speedlines);
	speedlines *= speed;
	
	// get distance from camera 
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	float dist = pixel_position.z ;
	float band = fract(dist) * 2.0 -1.0;
	band = smoothstep(0.0, 0.3, abs(band));
	band = pow(band, 4.0);
	speedlines *= clamp(dist + 20.0 ,0.0, 1.0);

	float col = max(bands, max(center, sides)) + speedlines;
	ALBEDO = basecolor * vec3(col, col, col);
	//ALBEDO = vec3(band);

}

void light() {
	vec3 worldLight = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = clamp(dot(worldNormal, worldLight), 0.0, 1.0);
    //vec3 l = LIGHT_COLOR 
	DIFFUSE_LIGHT += smoothstep(world_light_offset	, world_light_offset + 0.01, l) * ATTENUATION * LIGHT_COLOR / PI;
	//DIFFUSE_LIGHT = vec3(l);
}
