shader_type canvas_item;

// naming in UV system _x_y
uniform vec2 offset_0_0 = vec2(0.0, 0.0);
uniform vec2 offset_0_1 = vec2(0.0, 0.0);
uniform vec2 offset_1_0 = vec2(0.0, 0.0);
uniform vec2 offset_1_1 = vec2(0.0, 0.0);

vec2 sample_point(vec2 point) {
    // Corners for UV.y == 0
    vec2 x0y0 = vec2(0,0) - offset_0_0;
    vec2 x1y0 = vec2(1,0) - offset_1_0;
    // Get point along line UV.y == 0
    vec2 d_x_0 = x0y0 + (x1y0 - x0y0) * point.x;

    // Corners for UV.y == 1.0
    vec2 x0y1 = vec2(0, 1) - offset_0_1;
    vec2 x1y1 = vec2(1, 1) - offset_1_1;
    // Get point along line UV.y == 1
    vec2 d_x_1 = x0y1 + (x1y1 - x0y1) * point.x;
    // Get point for given UV.y
    return d_x_0 + (d_x_1 - d_x_0) * point.y;
}

void fragment() {
    //COLOR = vec4(UV.x, UV.y, .0, 1.0);
    //COLOR = texture(TEXTURE, UV);
    //COLOR = texture(TEXTURE, sample_point(UV));
}

uniform float speed = 5.0;
uniform float frequency_y = 1.0;
uniform float frequency_x = 0.4;
uniform float amplitude_y = 2.0;
uniform float amplitude_x = 0.7;
uniform float inclination = 8.0;

void vertex() {
	VERTEX.y -= sin((UV.x - TIME * speed) * frequency_y) * amplitude_y * UV.y;
	VERTEX.x += cos((UV.y - TIME * speed) * frequency_x) * amplitude_x;
	VERTEX.x -= UV.y * inclination;
	VERTEX += sample_point(UV);
}