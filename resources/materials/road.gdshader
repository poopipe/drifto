shader_type spatial;
//render_mode unshaded;
uniform float world_light_offset = 0.1;
//uniform float world_light_shadow_strength = 0.3;
uniform vec3 basecolor = vec3(0.2, 0.2, 0.2);
uniform float coverage = 0.0;
uniform float speed = 0.0;
uniform sampler2D noise: repeat_enable;
uniform float speedline_mask_dist = 0.0;
uniform float view_mask_offset = 0.1;

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

	// get fragcoord in view space
	vec2 frag_ndc = (FRAGCOORD.xy / VIEWPORT_SIZE) * 2.0 - 1.0;
	vec2 ratio = vec2( VIEWPORT_SIZE.x / VIEWPORT_SIZE.y, 1.0);
	
	float view_mask = length(frag_ndc*ratio) - view_mask_offset;
	view_mask = clamp(view_mask, 0.0, 1.0);
	view_mask *= view_mask * view_mask;
	view_mask *= (frag_ndc*ratio).y * coverage;
	// speedlines
	vec2 speedlines_pos = fract(UV);
	speedlines_pos *= vec2(1.0,94.0);
	float speedlines = texture(noise, speedlines_pos).x;
	float speedline_threshold = 0.6;
	
	
	
	// get distance from camera 
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, FRAGCOORD.z, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	float dist = pixel_position.z ;
	
	// bands
	float band_dist = 4.0;
	float band_scroll = pos.x ;//(TIME / 20.0);
	float band = abs(fract(band_scroll * band_dist) * 2.0 -1.0);
	band = smoothstep(0.8, 1.0, abs(band)) * 0.5;
	vec2 band_warp_uv = pos * vec2(1.0, 8.0);
	float band_warp = texture(noise, band_warp_uv).x;
	band_warp *= 0.4;
	band -= band_warp;
	band = clamp(band, 0.0, 1.0);
	band *= speed;


	// distance mask
	//float dist_mask = (dist + speedline_mask_dist);
	//dist_mask /= 20.0;
	//dist_mask = max(dist_mask, 0.0);
	//dist_mask = pow(dist_mask, 3.0);
	//dist_mask = clamp(dist_mask, 0.0, 1.0);
	//dist_mask *= coverage;

	speedlines = speedlines + band;
	speedlines = smoothstep(speedline_threshold, speedline_threshold + 0.3, speedlines);
	speedlines *= 4.0;
	
	
	float col = max(bands, max(center, sides));

	col += speedlines * view_mask;
	ALBEDO = basecolor * vec3(col, col, col);
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
