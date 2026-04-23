shader_type canvas_item;

uniform float time_scale : hint_range(0.1, 2.0) = 0.3;
uniform vec4 color_a : source_color = vec4(0.051, 0.067, 0.110, 1.0);
uniform vec4 color_b : source_color = vec4(0.102, 0.082, 0.196, 1.0);
uniform float grid_size : hint_range(10.0, 100.0) = 40.0;

void fragment() {
    vec2 uv = UV;
    float t = TIME * time_scale;

    // Hex grid efekti
    vec2 grid = fract(uv * grid_size + vec2(t * 0.1, 0.0));
    float line = step(0.95, max(grid.x, grid.y));

    // Degrade arka plan
    vec4 bg = mix(color_a, color_b, uv.y + sin(t * 0.5) * 0.1);

    // Grid çizgileri — çok hafif
    vec4 grid_color = vec4(0.482, 0.184, 0.745, 0.08);
    COLOR = mix(bg, grid_color, line * 0.4);
}
