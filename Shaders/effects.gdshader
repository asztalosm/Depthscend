shader_type canvas_item;
/*
shading_option:
0 = alap szín
1 = hit blink
2 = heal blink
3 = explosion blink
*/
uniform int shading_option = 0;
uniform float opacitystrength = 1.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (shading_option == 0) {
		color = texture(TEXTURE, UV);
	}
	else if (shading_option == 1) {
		color.rgb = vec3(1,1,1);
	}
	else if (shading_option == 2) {
		color.g = min(COLOR.g * 1.4, 1.0);
	}
	else if (shading_option == 3) {
		color.r = min(COLOR.r * opacitystrength, 1.0);
	}
	COLOR = color;
}
