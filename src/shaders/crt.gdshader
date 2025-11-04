shader_type canvas_item;
// Skips lighting and enables efficient alpha blending
render_mode blend_mix, unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform vec2 resolution = vec2(320.0, 180.0);

uniform float scan_line_amount : hint_range(0.0, 1.0) = 0.5;
uniform float warp_amount : hint_range(0.0, 1.0) = 0.05;
uniform float vignette_amount : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float grille_amount : hint_range(0.0, 1.0) = 0.05;
uniform float brightness_boost : hint_range(1.0, 2.0) = 1.2;

uniform bool low_quality = false;

void fragment() {
    vec2 uv = SCREEN_UV;

    // Warp effect (only in high quality)
    if (!low_quality) {
        vec2 delta = uv - 0.5;
        float warp_factor = dot(delta, delta) * warp_amount;
        uv += delta * warp_factor;
    }

    // Check if UV is out of bounds
    bool out_of_bounds = uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0;

    vec3 color = vec3(0.141, 0.141, 0.141); // default to #242424
    //vec3 color = vec3(0.102, 0.110, 0.173); // default to RGB color (26, 28, 44)

    if (!out_of_bounds) {
        // Scanline effect
        float scanline = 1.0;
        if (scan_line_amount > 0.0) {
            float line = abs(fract(uv.y * resolution.y) - 0.5) * 2.0;
            float strength = low_quality ? 0.25 : 0.5;
            scanline = mix(1.0, line, scan_line_amount * strength);
        }

        // Grille effect
        float grille = 1.0;
        if (grille_amount > 0.0) {
            float pattern = step(1.5, mod(uv.x * resolution.x, 3.0)) * 0.1 + 0.95;
            float strength = low_quality ? 0.25 : 0.5;
            grille = mix(1.0, pattern, grille_amount * strength);
        }

        // Sample screen texture
        color = texture(SCREEN_TEXTURE, uv).rgb * scanline * grille;

        // Vignette effect
        if (vignette_amount > 0.0) {
            vec2 v_uv = uv * (1.0 - uv);
            float vignette = v_uv.x * v_uv.y * 15.0 * vignette_intensity;
            float strength = low_quality ? 0.4 : 0.7;
            vignette = mix(1.0, vignette, vignette_amount * strength);
            color *= vignette;
        }

        // Brightness boost
        color *= brightness_boost;
    }

    COLOR.rgb = color;
    COLOR.a = 1.0;
}
