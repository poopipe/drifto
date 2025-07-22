shader_type spatial;
render_mode blend_mix;
render_mode unshaded;
//render_mode:depth_draw_always;

uniform float opacity;
uniform vec4 basecolor : source_color;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = basecolor.xyz;
	ALPHA = opacity;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
