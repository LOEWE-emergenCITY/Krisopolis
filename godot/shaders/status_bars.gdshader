shader_type canvas_item;
render_mode blend_mix,unshaded;

uniform vec4 color : source_color = vec4(0.48, 0.69, 0.87, 1.0);
uniform vec4 colorBG : source_color = vec4(1, 1, 1, 1);
uniform float amp = 0.015;
uniform float amp_c = 0.02;
uniform float freq = 8.0;
uniform float freq_c = 5.0;
uniform float shift = 0.0;

uniform float progress : hint_range(0.0, 1.0) = 0.5;


void fragment() {
	float sinus = sin( freq * (UV.y + TIME * 0.5 + shift) ) * amp + amp_c * sin(freq_c * (UV.y + TIME + shift));
	float shifted_level = progress - amp;
	float treshold = smoothstep(sinus + shifted_level, sinus + shifted_level + 0.01, UV.x);

	COLOR = mix(color, colorBG, treshold);
}
