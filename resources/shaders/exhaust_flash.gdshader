shader_type spatial;
render_mode unshaded;

uniform sampler2D noise: repeat_enable;

void vertex() {


}

void fragment() {
	// Called for every pixel the material is visible on.
	float nv = dot(NORMAL, VIEW);
	float noise_texture = texture(noise, UV * 2.0).x;
	
	nv *= noise_texture;
	
	nv = smoothstep(0.2, 0.2, nv);
	
	
	ALBEDO = vec3(1.0, 0.3, 0.0);
	ALPHA = nv;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
