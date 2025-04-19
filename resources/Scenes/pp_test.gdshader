shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

void vertex(){
	POSITION = vec4(VERTEX.xy * 2.0, 1.0, 1.0);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(SCREEN_TEXTURE, uv);
	vec2 offset = 0.5 / VIEWPORT_SIZE;
	vec3 normal = texture(NORMAL_TEXTURE, uv).rgb;
	float depth = texture(DEPTH_TEXTURE, uv).x;
	
	// normalise depth value
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	
	float ranged_depth = 1.0 - clamp( (linear_depth-20.0) / 200.0, 0.0, 1.0);
	float sky_mask = 1.0 - screen_color.w;
	ALBEDO = screen_color.xyz * clamp(ranged_depth + sky_mask, 0.0, 1.0);
	
	vec4 clipSpacePosition = vec4(SCREEN_UV * 2.0 - 1.0, texture(DEPTH_TEXTURE, SCREEN_UV).r, 1.0);
	vec4 viewSpacePosition = INV_PROJECTION_MATRIX * clipSpacePosition;
	viewSpacePosition /= viewSpacePosition.w;
	vec4 worldSpacePosition = INV_VIEW_MATRIX * viewSpacePosition;
	ALBEDO = worldSpacePosition.rgb;
	//ALBEDO = abs(viewSpacePosition.rgb);
	
	//ALBEDO = vec3(sky_mask) ;
	//ALBEDO = vec3(ranged_depth);
	
}
