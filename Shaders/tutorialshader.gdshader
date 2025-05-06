shader_type canvas_item;
render_mode blend_mix;

uniform vec2 offset = vec2(0.0, -8.0);
uniform vec4 modulate : source_color;

vec2 rotate(vec2 uv, vec2 pivot, float angle)
{
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
			vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}


void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	vec2 newuv = rotate(UV, vec2(0.5), 4.5);
	vec4 shadow = vec4(modulate.rgb, texture(TEXTURE, newuv - offset * ps).a * modulate.a * 0.35);
	vec4 col = texture(TEXTURE, UV);

	COLOR = mix(shadow, col, col.a);
}