shader_type canvas_item;

uniform float value : hint_range(0,1);
uniform sampler2D noise_texture;

void fragment()
{
	vec4 current_pixel = texture(TEXTURE,UV);
	vec4 noise_pixel = texture(noise_texture,UV);
	
	if(noise_pixel.r > value)
	{
		COLOR.a -= 1.0;
	}
	else
	{
		COLOR = current_pixel;
	}
}