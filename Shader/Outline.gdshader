shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // White by default
uniform float outline_thickness : hint_range(0.0, 10.0, 0.1) = 1.0;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	
	// If the current pixel isn't fully visible, check surrounding pixels
	if (col.a < 0.1) {
		vec2 size = TEXTURE_PIXEL_SIZE * outline_thickness;
		float alpha = 0.0;
		
		alpha += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
		alpha += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
		alpha += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
		alpha += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
		
		// Diagonal samples for smoother corners
		alpha += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
		alpha += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
		alpha += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
		alpha += texture(TEXTURE, UV + vec2(size.x, size.y)).a;

		if (alpha > 0.0) {
			COLOR = outline_color;
		} else {
			COLOR = vec4(0.0);
		}
	} else {
		// Hide the actual body 
		COLOR = vec4(0.0);
	}
}