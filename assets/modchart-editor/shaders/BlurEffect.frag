#pragma header

uniform float strength;
uniform float strengthY;

void main()
{

	vec4 color = vec4(0.0,0.0,0.0,0.0);
	vec2 uv = openfl_TextureCoordv;
	vec2 resolution = vec2(1280.0,720.0);
	vec2 direction = vec2(strength, strengthY);

	vec2 off1 = vec2(1.3333333333333333, 1.3333333333333333) * direction;
	color += flixel_texture2D(bitmap, uv) * 0.29411764705882354;
	color += flixel_texture2D(bitmap, uv + (off1 / resolution)) * 0.35294117647058826;
	color += flixel_texture2D(bitmap, uv - (off1 / resolution)) * 0.35294117647058826;

	gl_FragColor = color;
}