shader_type canvas_item;

// How fast the waves drift
uniform float wave_speed : hint_range(0.0, 4.0) = 0.5;
// How many wave rows fit top-to-bottom (lower = fewer, calmer rows)
uniform float wave_rows  : hint_range(2.0, 40.0) = 10.0;
// How much each line wiggles sideways (0.0 = perfectly straight lines)
uniform float wave_curve : hint_range(0.0, 0.1) = 0.02;
// Thickness of the bright line, as a fraction of one row (small = thin line)
uniform float line_width : hint_range(0.01, 0.4) = 0.05;
// Colour + opacity of the lines
uniform vec4  line_color : source_color = vec4(1.0, 1.0, 1.0, 0.5);

void fragment() {
    vec4 base = texture(TEXTURE, UV);

    // 1) A horizontal line position that gently waves as you move across X,
    //    then scrolls downward over time.
    float wavy_y = UV.y + sin(UV.x * TAU * 2.0 + TIME * wave_speed) * wave_curve;
    float w = wavy_y * wave_rows - TIME * wave_speed;

    // 2) Distance from the centre of the current row
    //    (0.0 right on the line, 0.5 halfway between two lines)
    float d = abs(fract(w) - 0.5);

    // 3) A crisp, 1-pixel-wide edge.
    //    fwidth(w) = how fast w changes per screen pixel.
    //    The smoothstep ONLY runs across that single-pixel rim, so the line is a
    //    SOLID flat band with a clean edge -- NOT a blurry gradient.
    float edge = fwidth(w);
    float line = 1.0 - smoothstep(line_width - edge, line_width + edge, d);

    vec3 col = mix(base.rgb, line_color.rgb, line * line_color.a);
    COLOR = vec4(col, base.a);
}