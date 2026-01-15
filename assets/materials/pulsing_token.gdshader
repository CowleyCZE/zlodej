shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform float ring_width : hint_range(0.0, 0.5) = 0.05;
uniform float pulse_speed : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    // Základní kruh
    float alpha = smoothstep(0.4, 0.39, dist);
    
    // Pulzující kruh
    float pulse = fract(TIME * pulse_speed * 0.5);
    float ring_dist = pulse * 0.5; // Expanduje od 0 do 0.5
    float ring_alpha = 1.0 - smoothstep(ring_width, 0.0, abs(dist - ring_dist));
    
    // Fade out ringu na okrajích
    ring_alpha *= (1.0 - pulse);
    
    // Initials text placeholder (simple visual trick - darker center)
    // float text_placeholder = smoothstep(0.15, 0.16, dist);
    
    vec4 final_color = base_color * COLOR; // Multiply by Modulate color
    final_color.a = max(alpha * 0.8, ring_alpha);
    
    COLOR = final_color;
}
