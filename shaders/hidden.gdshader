shader_type canvas_item;

void fragment() {
	vec4 pixel_color = texture(TEXTURE, UV);
	if(pixel_color.a > .01){
		COLOR = vec4(0, 0, 0, 255);
	}
}

