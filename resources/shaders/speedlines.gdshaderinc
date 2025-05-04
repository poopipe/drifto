float get_speed_lines(vec2 pos, float view_mask, sampler2D speedlines_sampler, vec2 pos_scale){
	// speedlines
	vec2 speedlines_pos = fract(pos.yx);
	speedlines_pos *= pos_scale;
	float speedlines = texture(speedlines_sampler, speedlines_pos).x;
	speedlines = smoothstep(0.0, 0.2, speedlines);
	speedlines = 1.0-speedlines;
	return clamp(view_mask-speedlines, 0.0, 1.0);
}