shader_type spatial;
//render_mode unshaded;
uniform float world_light_offset = 0.1;
//uniform float world_light_shadow_strength = 0.3;
uniform vec3 basecolor = vec3(0.2, 0.2, 0.2);
uniform vec3 center_line_color = vec3(0.6, 0.4, 0.0) ;
uniform vec3 side_line_color = vec3 (0.6);

uniform float coverage = 0.0;
uniform float drift_amount = 0.0;
uniform sampler2D noise: repeat_enable;
uniform sampler2D basecolor_map: repeat_enable;
//uniform float speedline_mask_dist = 0.0;
uniform float view_mask_offset = 0.1;

void vertex() {
}

float get_bands(vec2 p, float dist){
	float r = step(0.5, fract(p.x * dist));
	r *= 0.125;
	return r + 0.5;
}

float get_view_mask(vec4 frag_coord, vec2 viewport_size, float offset, float amount){
	// view space:  mask circle in the middle and the top half of screen
	vec2 frag_ndc = (frag_coord.xy / viewport_size) * 2.0 - 1.0;
	vec2 ratio = vec2( viewport_size.x / viewport_size.y, 1.0);
	
	float view_mask = length(frag_ndc*ratio) - offset;
	view_mask = clamp(view_mask, 0.0, 1.0);
	view_mask *= view_mask * view_mask;
	view_mask *= (frag_ndc*ratio).y * amount;
	return clamp(view_mask, 0.0, 1.0);
}

void fragment() {
	vec2 pos = fract(UV);

	// surface texture
	vec2 texture_uv = pos * vec2(12.0, 8.0);
	float surface = texture(basecolor_map, texture_uv).x;
	//surface = clamp(surface, 0.0, 1.0);
	surface *= 0.6;

	float bands = get_bands(pos, 1.0);

	// get road markings
	float lines = fract(pos.y * 8.0);
	lines = abs(lines * 2.0 - 1.0);
	
	float center_line = 1.0 - step(0.025, lines);
	float center_gap = fract(pos.x * 8.0);
	center_gap = step(0.4, center_gap);
	//center_line -= center_gap;
	float side_lines = step(0.875, lines);
	side_lines = side_lines - step(0.92, lines);
	// create road surface
	bands -= surface;
	bands = clamp(bands, 0.0, 1.0);
	
	vec3 road_surface = vec3(bands) * basecolor;
	road_surface = mix(road_surface, center_line_color, center_line);
	road_surface = mix(road_surface, side_line_color, side_lines);
	
	
	// view space masking
	float view_mask = get_view_mask(FRAGCOORD, VIEWPORT_SIZE, view_mask_offset, coverage);
	
	// speedlines
	vec2 speedlines_pos = fract(UV);
	speedlines_pos *= vec2(2.0,94.0);
	float speedlines = texture(noise, speedlines_pos).x;
	float speedline_threshold = 0.6;

	
	// process speed lines 
	speedlines = smoothstep(speedline_threshold, speedline_threshold + 0.3, speedlines);
	speedlines *= 4.0;
	speedlines = clamp(speedlines, 0.0, 0.2);
	speedlines *= view_mask;
	// combine lines and bands
	//float col = max(drift_bands, road_surface);
	vec3 col = clamp(road_surface, 0.0, 1.0);
	// combine speedlines
	col -= speedlines;

	
	ALBEDO = col;// * basecolor;
	//ALBEDO -= vec3(speedlines);
	//ALBEDO = vec3(abs(fract(pos.y * 8.0)*2.0 - 1.0));
	//ALBEDO = vec3(view_mask);

}

void light() {
	vec3 worldLight = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = clamp(dot(worldNormal, worldLight), 0.0, 1.0);
    //vec3 l = LIGHT_COLOR 
	DIFFUSE_LIGHT += smoothstep(world_light_offset	, world_light_offset + 0.01, l) * ATTENUATION * LIGHT_COLOR / PI;
	//DIFFUSE_LIGHT = vec3(l);
}
