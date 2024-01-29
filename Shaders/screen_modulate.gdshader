shader_type canvas_item;

uniform vec4 color : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV) * color;
}
