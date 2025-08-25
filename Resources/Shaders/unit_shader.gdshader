shader_type canvas_item;
uniform vec4 color_to_replace : source_color = vec4(0.0, 0.0, 0.0, 1.0); // RGBAlpha Black
uniform vec4 new_color : source_color = vec4(0.6, 0.2, 0.4, 1.0); //
uniform float tolerance : hint_range(0.0, 2.0) = 0.01;

uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float flash_modifier : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	
	if (distance(current_color, color_to_replace) < tolerance) {
		current_color = new_color;
	}
	
	current_color.rgb = mix(current_color.rgb, flash_color.rgb, flash_modifier);
	
	COLOR = current_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
