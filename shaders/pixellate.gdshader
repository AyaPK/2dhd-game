shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 20.0) = 4.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Get screen UV (normalized coordinates)
    vec2 uv = SCREEN_UV;

    // Snap UV to pixel grid
    uv = floor(uv * pixel_size) / pixel_size;

    // Sample the screen texture with snapped UV
    vec4 col = texture(SCREEN_TEXTURE, uv);

    COLOR = col;
}
