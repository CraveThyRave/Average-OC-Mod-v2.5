#pragma header

uniform float grayness;
uniform float rippleTime;
uniform float rippleStrength;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    uv.x = clamp(uv.x + sin(uv.y * 20.0 - rippleTime * 3.141593) * (0.75 * rippleStrength) * grayness / openfl_TextureSize.x, 0.0, 1.0);

    vec4 color = flixel_texture2D(bitmap, uv);
    float intensity = dot(color.rgb, vec3(1.0 / 3.0)) / max(color.a, 0.0001);
    float tone = pow(clamp(intensity, 0.0, 1.0), 0.8);
    float shadowLift = 0.30 * (1.0 - smoothstep(0.0, 0.55, tone));
    vec3 greyScale = vec3((tone + shadowLift) * color.a);
    gl_FragColor = vec4((color.rgb*abs(1.-grayness))+(greyScale*grayness), color.a);
}