shader_type canvas_item;

uniform vec4 background_color : source_color = vec4(0.043, 0.102, 0.165, 1.0); // #0B1A2A
uniform vec4 grid_color : source_color = vec4(0.106, 0.176, 0.247, 0.2); // #1B2D3F
uniform vec4 accent_color : source_color = vec4(0.224, 0.627, 0.929, 0.3); // #39A0ED
uniform float grid_size = 64.0;
uniform float scanline_count = 240.0;
uniform float vignette_intensity = 0.5;
uniform float reveal_intensity : hint_range(0.0, 1.0) = 1.0;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Noise for unrevealed areas
    float n = hash(uv + vec2(TIME * 0.01));
    vec4 noise_col = vec4(n, n, n, 1.0) * 0.08;
    
    // Thick Grid logic (90s tech style)
    vec2 grid_uv = fract(uv * (vec2(1080.0, 1920.0) / grid_size));
    float grid = step(0.96, grid_uv.x) + step(0.96, grid_uv.y);
    float subgrid = step(0.99, fract(grid_uv * 5.0).x) + step(0.99, fract(grid_uv * 5.0).y);
    
    // Scanlines (pronounced)
    float scanline = sin(uv.y * scanline_count * PI * 2.0) * 0.06;
    
    // Vignette
    float dist = distance(uv, vec2(0.5));
    float vignette = smoothstep(0.9, 0.1, dist * vignette_intensity);
    
    // Combine
    vec4 col = mix(vec4(0.0, 0.05, 0.1, 1.0), background_color, reveal_intensity);
    col += grid * grid_color * 2.0 * reveal_intensity;
    col += subgrid * grid_color * 0.5 * reveal_intensity;
    col += grid * accent_color * 0.3 * reveal_intensity;
    col -= scanline;
    col += noise_col * (1.0 - reveal_intensity);
    col *= (vignette + 0.2); // Keep corners somewhat visible
    
    COLOR = col;
}