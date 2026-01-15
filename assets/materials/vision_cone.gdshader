shader_type canvas_item;

uniform vec4 cone_color : source_color = vec4(0.2, 0.4, 1.0, 0.3);
uniform float glow_intensity = 1.5;

void fragment() {
    float dist = distance(UV, vec2(0.5, 0.0)); // Radial from origin
    float alpha = cone_color.a * (1.0 - dist);
    COLOR = vec4(cone_color.rgb * glow_intensity, alpha);
}
