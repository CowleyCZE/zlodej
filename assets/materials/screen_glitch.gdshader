shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform float shake_speed = 30.0;
uniform float color_drift = 0.02;

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    if (intensity <= 0.0) {
        COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
    } else {
        vec2 uv = SCREEN_UV;
        float time = TIME * shake_speed;
        
        // Horizontal shake
        float shake = (rand(vec2(floor(uv.y * 10.0), time)) - 0.5) * intensity * 0.05;
        
        // Color drift (Chromatic Aberration)
        float r = texture(SCREEN_TEXTURE, uv + vec2(shake + color_drift * intensity, 0.0)).r;
        float g = texture(SCREEN_TEXTURE, uv + vec2(shake, 0.0)).g;
        float b = texture(SCREEN_TEXTURE, uv + vec2(shake - color_drift * intensity, 0.0)).b;
        
        // Digital blocks / noise
        if (rand(vec2(time, floor(uv.y * 20.0))) < intensity * 0.2) {
            r = rand(uv + time);
            g = rand(uv + time + 1.0);
            b = rand(uv + time + 2.0);
        }

        COLOR = vec4(r, g, b, 1.0);
    }
}
