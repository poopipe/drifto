shader_type canvas_item;
uniform sampler2D noise: repeat_enable;

uniform vec2 skiddies_offset = vec2(0.0, 0.0);
uniform vec2 polar_center = vec2(0.555, 0.255);
uniform float polar_scale = 3.06;
uniform float polar_noise_offset = -0.15;
uniform vec4 background_color : source_color = vec4(1.0,1.0,1.0,1.0);
uniform vec4 skid_color : source_color = vec4(0.25, 0.167, 0.0, 1.0);


void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 polar_coords(vec2 pos){
	float u = atan(pos.y, pos.x);
	float v = length(pos - vec2(0.0,0.0));
	return vec2(u, v);
}

float quantise(float g, float steps){
	return floor(g * steps) / steps;
}

float get_rings(vec2 pos, vec2 center, float scale, float noise_offset){
	// generate a set of rings
	vec2 polar_uv = polar_coords((pos / scale) + center);
	
	float polar_steps = texture(noise, vec2(clamp(polar_uv.y, 0.8, 2.0), noise_offset)).x;
	
	polar_steps = quantise(polar_steps, 8.0);
	polar_steps = step(polar_steps, 0.4);
	return polar_steps;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;

	float aspect = resolution.y / resolution.x;
	//float neg = 0.5;

	vec2 locked_uv =  (UV * 2.0 - 1.0) / vec2(aspect, 1.0);
	
	
	// magic number for image aspect ratio
	float skiddies_aspect = 16.0 / 9.0;
	vec2 skiddies_uv = (locked_uv / vec2(skiddies_aspect, 1.0)) + 0.5;
	skiddies_uv += skiddies_offset;
	skiddies_uv = clamp(skiddies_uv, 0.0, 1.0);
	
	float time = TIME * 0.3;
	vec2 wobble = 	vec2( sin(time) * 0.02, sin(time)  * 0.02);
	vec2 wobble_b = vec2( cos(time) * 0.015, cos(time)  * 0.015);
	float rings_a = get_rings(locked_uv, polar_center + wobble, polar_scale, polar_noise_offset );
	float rings_b = get_rings(locked_uv, polar_center + vec2(-0.02, 0.02) + wobble_b, polar_scale - 0.01, polar_noise_offset+0.02);
	
	rings_a += clamp(rings_b + 0.1, 0.0, 1.0);
	
	vec4 color_skiddies = mix(skid_color, background_color, rings_a);
	
	vec4 color_polar = vec4(rings_a,rings_a,rings_a, 1.0);
	COLOR = color_skiddies;
	//COLOR = color_polar;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
