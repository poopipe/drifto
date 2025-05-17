shader_type spatial;

#include "res://resources/shaders/viewmask.gdshaderinc"
#include "res://resources/shaders/speedlines.gdshaderinc"
//render_mode unshaded;
uniform float world_light_offset = 0.1;
//uniform float world_light_shadow_strength = 0.3;
uniform vec3 basecolor : source_color = vec3(0.2, 0.2, 0.2);
uniform vec3 center_line_color : source_color = vec3(0.6, 0.4, 0.0) ;
uniform vec3 side_line_color : source_color = vec3(0.6);
uniform vec3 angle_line_color : source_color = vec3(0.6);

uniform float coverage = 0.0;

uniform sampler2D noise: repeat_enable;
uniform sampler2D basecolor_map: repeat_enable;
uniform float view_mask_offset = 0.1;

void vertex() {
}

float get_bands(vec2 p, float dist){
	float r = step(0.5, fract(p.x * dist));
	r *= 0.125;
	return r + 0.5;
}

float get_road_mask(vec2 p){
	vec2 boundary_pos = p * vec2(1.0, 8.0);
	float pos_width = boundary_pos.y - 1.0;
	float center_mask = step(pos_width, 0.77);
	float left_mask = step(pos_width, 0.23);
	return center_mask - left_mask;
}

float get_skew_lines(vec2 p){
	vec2 skew_pos = p * vec2(1.0, 8.0);
	float skew_across = abs((skew_pos.y - 1.0) * 2.0 - 1.0) + (p.x * 12.0);
	return step(abs(sin( skew_across * TAU * 1.0)), 0.75);
	
}

void fragment() {
	vec2 pos = fract(UV);

	// surface texture
	vec2 texture_uv = pos * vec2(12.0, 16.0);
	float surface = texture(basecolor_map, texture_uv).x;
	surface *= 1.0;

	float bands = get_bands(pos, 1.0);

	// get road markings
	float lines = fract(pos.y * 8.0);
	lines = abs(lines * 2.0 - 1.0);
	float center_line = 1.0 - step(0.01, lines);
	float center_gap = fract(pos.x * 8.0);
	center_gap = step(0.4, center_gap);
	float side_lines = step(0.475, lines);
	side_lines = side_lines - step(0.50, lines);
	// road mask
	float road_mask =  get_road_mask(pos);
	// angled stripes
	float skew_lines = get_skew_lines(pos);
	skew_lines = skew_lines * (1.0 - road_mask);
	
	// create road surface
	bands -= surface;
	bands = clamp(bands, 0.0, 1.0);
	
	vec3 road_surface = vec3(bands) * basecolor;
	road_surface = mix(road_surface, center_line_color, center_line);
	road_surface = mix(road_surface, side_line_color, side_lines);
	road_surface = mix(road_surface, angle_line_color, skew_lines);
	
	
	// view space masking
	float view_mask = get_view_mask(FRAGCOORD, VIEWPORT_SIZE, view_mask_offset, coverage);
	// speedlines
	float speedlines = get_speed_lines(fract(UV.xy), view_mask, noise , vec2(16.0, 4.0));
	
	// combine lines and bands
	vec3 col = clamp(road_surface, 0.0, 1.0);
	// combine speedlines
	col -= speedlines;

	ALBEDO = col;
	

	//ALBEDO = vec3(speedlines);
}

void light() {
	vec3 worldLight = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = clamp(dot(worldNormal, worldLight), 0.0, 1.0);
	DIFFUSE_LIGHT += smoothstep(world_light_offset	, world_light_offset + 0.01, l) * ATTENUATION * LIGHT_COLOR / PI;
}
