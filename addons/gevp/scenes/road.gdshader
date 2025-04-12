shader_type spatial;
//render_mode unshaded;

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


	float col = max(bands, max(center, sides));
	ALBEDO = vec3(col, col, col);

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
