shader_type canvas_item;

uniform vec4 background_color : source_color = vec4(0.043, 0.102, 0.165, 1.0);
uniform vec4 line_color : source_color = vec4(0.0, 0.4, 1.0, 0.15);
uniform float grid_size = 64.0;
uniform float scanline_count = 360.0;
uniform float vignette_intensity = 0.4;
uniform float aberration_amount = 0.002;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Grid logic
    vec2 grid_uv = fract(uv * (vec2(1280.0, 720.0) / grid_size));
    float grid = step(0.98, grid_uv.x) + step(0.98, grid_uv.y);
    
    // Scanlines
    float scanline = sin(uv.y * scanline_count * PI * 2.0) * 0.04;
    
    // Vignette
    float dist = distance(uv, vec2(0.5));
    float vignette = smoothstep(0.8, 0.2, dist * vignette_intensity);
    
    // Combine
    vec4 col = background_color;
    col += grid * line_color;
    col -= scanline;
    col *= vignette;
    
    COLOR = col;
}