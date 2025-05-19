vec3 get_cubemap_uv(mat4 inv_view_mat, vec3 norm, vec3 cam_pos, vec3 node_pos){
	vec4 n = normalize(inv_view_mat * vec4(norm, 0.0));
	vec3 view = normalize(cam_pos - node_pos);
	vec3 reflection_vector = normalize(-reflect(view, n.xyz));
	return reflection_vector;
}