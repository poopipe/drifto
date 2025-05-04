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