#pragma header

uniform float effectStrength;
uniform vec4 effectArea;

vec3 curve(vec3 value)
{
    vec3 lower = step(value, vec3(0.5));
    vec3 base = 2.0 * mix(1.0 - value, value, lower);
    base = vec3(pow(base.r, 2.1), pow(base.g, 2.3), base.b * base.b) * 0.5;
    base = mix(1.0 - base, base, lower);
    return vec3(base.r, pow(base.g, 0.85), pow(base.b, 0.8));
}

float flareSample(vec2 uv, vec2 offset, float threshold)
{
    float a = texture2D(bitmap, uv + offset).r;
    float b = texture2D(bitmap, uv - offset).r;
    return step(threshold, max(a, b));
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 original = texture2D(bitmap, uv);
    vec2 pixelPosition = uv * openfl_TextureSize;
    if(effectArea.z > effectArea.x && (pixelPosition.x < effectArea.x || pixelPosition.y < effectArea.y || pixelPosition.x > effectArea.z || pixelPosition.y > effectArea.w)) { gl_FragColor = original; return; }
    float strength = clamp(effectStrength, 0.0, 1.0);
    if(strength <= 0.001) { gl_FragColor = original; return; }
    if(original.a == 0.0) { gl_FragColor = vec4(0.0); return; }
    if(uv.y < 0.1 || uv.y > 0.9)
    {
        gl_FragColor = vec4(original.rgb * (1.0 - strength), original.a);
        return;
    }
    vec2 delta = uv - 0.5;
    vec2 aberration = 0.022 * delta * delta * delta;
    vec3 color = vec3(0.0, original.g * 0.9961, 0.0);
    float weight = 0.75;
    for(int i = 1; i <= 4; i++)
    {
        color.r += texture2D(bitmap, uv - (float(i) * 2.0 - 0.6666666667) * aberration).r * weight;
        color.b += texture2D(bitmap, uv + (float(i) * 2.0 - 0.6666666667) * aberration).b * weight;
        weight *= 0.25;
    }
    color *= 0.97;
    vec3 mapped = (color * (2.51 * color + 0.03)) / (color * (2.43 * color + 0.59) + 0.14);
    color = mix(color, mapped, 0.6);
    vec3 powered = pow(color, vec3(2.2));
    vec3 glow = powered * (1.0 + 0.99998 * smoothstep(0.58, 0.78, dot(powered, vec3(1.0 / 3.0))));
    color = mix(color, clamp(0.02 + glow * 1.08, 0.0, 1.0), 0.5);
    color = mix(color, curve(color), 0.45);
    float flare = step(0.94, original.r);
    for(int j = 0; j < 9; j++)
    {
        float distance = 9.5 - float(j);
        flare += flareSample(uv, vec2(distance / 300.0, 0.0), 0.98465018) * (1.0 - distance / 10.5);
    }
    flare += flareSample(uv, vec2(0.5 / 300.0, 0.0), 0.98465018) * 2.0;
    for(int j = 0; j < 7; j++)
    {
        float distance = 5.25 - float(j);
        flare += flareSample(uv, vec2(0.0, distance / 300.0), 0.99845431) * (1.0 - distance / 10.5) * 0.15;
    }
    color += flare * vec3(0.55, 0.25, 1.0) * 0.055;
    color *= vec3(0.9744, 0.9552, 1.032);
    gl_FragColor = vec4(mix(original.rgb, color, strength), original.a);
}
