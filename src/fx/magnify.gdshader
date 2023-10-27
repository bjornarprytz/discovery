shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float magnification : hint_range(1.0, 1000.0);
uniform float distortion_strength : hint_range(0.0, 1.0);
uniform float sharpness_radius : hint_range(0.0, 0.5);

void fragment() {
    vec2 uv = UV; // Get the fragment's UV coordinates

    // Calculate the distance from the center
    vec2 center = vec2(0.5, 0.5); // Center of the viewport
    vec2 diff = uv - center;
    float distance = length(diff);

    // Apply magnification
    vec2 magnified_uv = center + diff / magnification;

    // Apply distortion based on distance from the center
    float distortion_factor = smoothstep(0.0, sharpness_radius, distance);
    vec2 distortion = diff * distortion_strength * distortion_factor;

    // Combine magnification and distortion
    vec2 final_uv = magnified_uv + distortion;

    // Sample the screen texture using the final UV
    COLOR = texture(screen_texture, final_uv);
}
