shader_type spatial;
//render_mode unshaded;
uniform float world_light_offset = 0.1;
//uniform float world_light_shadow_strength = 0.3;
uniform vec3 basecolor = vec3(0.2, 0.2, 0.2);

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
	ALBEDO = basecolor * vec3(col, col, col);

}

void light() {
	vec3 worldLight = (INV_VIEW_MATRIX * vec4(LIGHT, 0.0)).xyz;
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = clamp(dot(worldNormal, worldLight), 0.0, 1.0);
    //vec3 l = LIGHT_COLOR 
	DIFFUSE_LIGHT += smoothstep(world_light_offset	, world_light_offset + 0.01, l) * ATTENUATION * LIGHT_COLOR / PI;
	//DIFFUSE_LIGHT = vec3(l);
}
