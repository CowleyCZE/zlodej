shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1080) = 300.0;
uniform float scanline_opacity : hint_range(0, 1) = 0.1;
uniform float vignette_intensity : hint_range(0, 1) = 0.4;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(screen_texture, SCREEN_UV);
	
	// Scanlines
	float s = sin(SCREEN_UV.y * scanline_count * PI * 2.0);
	s = (s * 0.5 + 0.5);
	color.rgb -= s * scanline_opacity;
	
	// Vignette
	float d = distance(SCREEN_UV, vec2(0.5));
	color.rgb *= (1.0 - d * vignette_intensity);
	
	COLOR = color;
}
