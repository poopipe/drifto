shader_type spatial;
render_mode blend_add;
render_mode unshaded;
uniform vec4 basecolor : source_color;
uniform float intensity = 1.0;
void vertex() {
	// Called for every vertex the material is visible on.
	
}
float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow(( clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}


void fragment() {
	
	vec3 vcol = COLOR.xyz * fresnel(2.0, NORMAL, VIEW);
	vcol *= vcol;
	vcol *= intensity;
    ALBEDO = vcol * basecolor.xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
