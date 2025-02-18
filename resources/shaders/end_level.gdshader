// NOTE: Shader automatically converted from Godot Engine 4.3.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_never, unshaded;

uniform float max_depth = 0.8;

uniform vec3 offset = vec3(0,0,0.5);
uniform vec3 direction = vec3(0,0,1);
uniform vec4 albedo : source_color;
uniform sampler2D depth_tex : hint_depth_texture;

varying vec3 offset_view;
varying vec3 direction_view;

void vertex() {
	offset_view = (MODELVIEW_MATRIX * vec4(offset, 1)).xyz;
	direction_view = MODELVIEW_NORMAL_MATRIX * direction;
}

void fragment() {
	ALBEDO = albedo.rgb;
	
	float depth = texture(depth_tex, SCREEN_UV).x;
	//#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	//#else
	//vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	//#endif
	if (ndc.z < -.999)
		discard;
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	//vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  	//vec3 world_position = world.xyz / world.w;
	
	//float darkness = (VERTEX.z - view.z) / max_depth;
	float darkness = dot(view.xyz - offset_view, -direction_view) / max_depth;
	
	ALPHA *= clamp(pow(darkness, 0.6), 0, 1);
}
