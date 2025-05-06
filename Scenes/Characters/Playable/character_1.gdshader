shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture;
uniform vec4 invistreecolor: source_color = vec4(0,0,0,0.5);

void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV); // fa színe
	vec4 sprite_color = texture(TEXTURE, UV); //milyen színű legyen a sprite ha fa mögött van
	if(all(lessThan(abs(sprite_color - screen_color), vec4(0.01)))) {
		COLOR = sprite_color; //karakter látszódik
	}
	else {
		COLOR = vec4(invistreecolor.rgb, invistreecolor.a * sprite_color.a);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
