shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float screen_curvature : hint_range(0.0, 0.2) = 0.03;
uniform float scanline_brightness : hint_range(0.0, 1.0) = 0.22;
uniform float scanline_density : hint_range(0.1, 10.0) = 1.0;
uniform float vignette_intensity : hint_range(0.0, 1.0) = 0.45;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 centered_uv = uv - vec2(0.5);

    // Barrel (curvatura)
    float barrel_dist = dot(centered_uv, centered_uv) * screen_curvature;
    uv += centered_uv * barrel_dist;

    // fuera de pantalla -> descartamos
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
        discard;
    }

    // obtener tamaño de textura (height)
    ivec2 ts = textureSize(SCREEN_TEXTURE, 0);
    float height = float(ts.y);

    // muestrear color base
    vec4 color = texture(SCREEN_TEXTURE, uv);

    // ---- SCANLINES (suaves) ----
    // s va -1..1 por fila; pattern 0..1
    float s = sin(uv.y * height * 3.14159265 * scanline_density);
    float pattern = (s + 1.0) * 0.5; // 0..1
    float scan_factor = 1.0 - scanline_brightness * (1.0 - pattern);
    color.rgb *= scan_factor;

    // ---- VIGNETTE ----
    float dist = length(centered_uv);
    float vig = mix(1.0, 1.0 - vignette_intensity, smoothstep(0.0, 0.9, dist));
    color.rgb *= vig;

    COLOR = color;
}
