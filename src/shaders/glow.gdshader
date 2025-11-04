shader_type canvas_item;
render_mode blend_premul_alpha;

uniform float radius = 5.0;
uniform float amount = 0.25;

void fragment() {
    vec2 ps = TEXTURE_PIXEL_SIZE;
    vec4 base_color = COLOR;
    vec4 glow = base_color;

    vec2 r = vec2(radius, 0.0);
    vec2 u = vec2(0.0, radius);

    glow += texture(TEXTURE, UV + r * ps);
    glow += texture(TEXTURE, UV - r * ps);
    glow += texture(TEXTURE, UV + u * ps);
    glow += texture(TEXTURE, UV - u * ps);

    glow /= 5.0;
    glow *= amount;
    base_color.rgb *= base_color.a;

    COLOR = glow + base_color;
}
