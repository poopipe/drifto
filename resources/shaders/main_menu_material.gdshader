shader_type canvas_item;
uniform sampler2D texture_color : source_color, filter_linear_mipmap, repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment(){
	vec4 col = texture(texture_color, SCREEN_UV);
	vec4 bgcol = vec4(0.4, 0.6, 0.9, 1.0);
	vec3 out_col = mix(bgcol.xyz, col.xyz,col.w );
	COLOR = vec4(out_col, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
