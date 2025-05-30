shader_type spatial;
#include "res://resources/shaders/viewmask.gdshaderinc"
#include "res://resources/shaders/speedlines.gdshaderinc"

uniform vec4 basecolor : source_color;
uniform float world_light_strength = 0.2;
uniform float view_mask_offset = 0.45;
uniform float coverage = 0.0;

uniform sampler2D noise: repeat_enable;
uniform sampler2D divider: repeat_enable;

uniform vec2 uv_scale = vec2(8.0, 4.0);
uniform vec2 uv_offset = vec2(0.0, 0.0);

void vertex() {
	// Called for every vertex the material is visible on.

}

void fragment() {
	// Called for every pixel the material is visible on.

	// consider putting the depth cue into the shaders rather than using fog
	// fog is too soft a falloff and it makes me sad
	vec3 worldNormal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float l = dot(worldNormal, vec3(0.0,1.0,0.0));

	// view space masking
	float view_mask = get_view_mask(FRAGCOORD, VIEWPORT_SIZE, view_mask_offset, coverage);
	float speedlines = get_speed_lines(fract(UV.xy), view_mask, noise, vec2(0.25, 4.0) );
	speedlines *= 1.5;

	// dividers
	vec2 divider_uv = (UV.xy * vec2(16.0, 1.0)) * uv_scale + uv_offset ;
	float divider_mask = clamp(1.0 - floor(mod(divider_uv.x, 8.0)), 0.0, 1.0);
	float dividers = texture(divider, divider_uv).x * divider_mask;

	l = l * world_light_strength ;
	vec3 col = basecolor.xyz - dividers;
	//col = mix(basecolor.xyz, vec3(0.0), speedlines);
	col -= speedlines;
	ALBEDO = col  + l ;

}

void light() {

	float l = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
	l = smoothstep(0.0, 0.1	, l);
	DIFFUSE_LIGHT += vec3(l * ATTENUATION) * LIGHT_COLOR / PI;
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, vec3(0.025));

}