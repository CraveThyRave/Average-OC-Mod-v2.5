#pragma header

uniform vec2 u_offset;
uniform vec2 u_scale;

uniform float u_time;
uniform float u_mix;

const vec2 k = vec2(
	(sqrt(3.0) - 1.0) / 2.0,
	(3.0 - sqrt(3.0)) / 6.0
);

vec2 hash(vec2 v) {
	v = vec2(dot(v, vec2(127.1, 311.7)), dot(v, vec2(269.5, 183.3)));
	return 2.0 * fract(sin(v) * 43758.5453123) - 1.0;
}

float noise(vec2 v) {
	vec2 i = floor(v + (v.x + v.y) * k.x);
	vec2 a = v - i + (i.x + i.y) * k.y;
	float m = step(a.y, a.x); 
	vec2 o = vec2(m, 1.0 - m);
	vec2 b = a - o + k.y;
	vec2 c = a - 1.0 + 2.0 * k.y;
	vec3 h = max(0.5 - vec3(dot(a, a), dot(b, b), dot(c, c)), 0.0);
	vec3 n = pow(h, vec3(4.0)) * vec3(dot(a, hash(i)), dot(b, hash(i + o)), dot(c, hash(i + 1.0)));
	return dot(n, vec3(70.0));
}

void main() {
	vec2 uv = openfl_TextureCoordv * openfl_TextureSize / openfl_TextureSize.y * u_scale - u_time / 1e1;
	vec3 weight = vec3(0.0);
	for (float i = 0.0; i < 2.0; i++) {
		uv = vec2(
			noise(uv + 1e2 + u_offset.x + u_time / 17.0 + i),
			noise(uv + 1e1 + u_offset.y)
		);
		
		weight.r += sin(1e1 * (uv.x - uv.y - 0.01));
		weight.g += sin(1e1 * (uv.x - uv.y));
		weight.b += sin(1e1 * (uv.x - uv.y + 0.01));
	}
	
	// The old 0.9-1.0 range was effectively invisible on the solid-white stage
	// backgrounds. Keep u_mix as a conventional 0-1 blend while giving the
	// generated void pattern enough contrast to be clearly visible.
	vec3 voidColor = smoothstep(-0.25, 0.25, weight) * 0.75 + 0.1;
	gl_FragColor = vec4(mix(vec3(1.0), voidColor, clamp(u_mix, 0.0, 1.0)), 1.0)
		* flixel_texture2D(bitmap, openfl_TextureCoordv);
}
