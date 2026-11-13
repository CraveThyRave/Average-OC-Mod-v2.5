#pragma header

uniform float effectStrength;
uniform vec4 effectArea;
uniform vec2 effectTextureSize;
uniform vec2 effectTextureOffset;

vec4 sampleSource(vec2 uv)
{
    return texture2D(bitmap, uv);
}

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
    float a = sampleSource(uv + offset).r;
    float b = sampleSource(uv - offset).r;
    return step(threshold, max(a, b));
}

void main()
{
    vec2 sourceSize = effectTextureSize.x > 0.0 ? effectTextureSize : openfl_TextureSize;
    vec2 uv = (openfl_TextureCoordv * openfl_TextureSize + effectTextureOffset) / sourceSize;
    vec2 texUV = openfl_TextureCoordv;
    vec2 textureScale = sourceSize / openfl_TextureSize;
    vec4 original = sampleSource(texUV);
    vec2 pixelPosition = uv * sourceSize;
    if(effectArea.z > effectArea.x && (pixelPosition.x < effectArea.x || pixelPosition.y < effectArea.y || pixelPosition.x > effectArea.z || pixelPosition.y > effectArea.w)) { gl_FragColor = original; return; }
    float strength = clamp(effectStrength, 0.0, 1.0);
    if(strength <= 0.001) { gl_FragColor = original; return; }
    if(original.a == 0.0) { gl_FragColor = vec4(0.0); return; }
    if(uv.y < 0.1 || uv.y > 0.9)
    {
        gl_FragColor = vec4(original.rgb * (1.0 - strength), original.a);
        return;
    }
    vec2 aberration = vec2(0.75 / openfl_TextureSize.x, 0.0);
    vec3 color = vec3(0.0, original.g * 0.9961, 0.0);
    float weight = 0.75;
    for(int i = 1; i <= 4; i++)
    {
        color.r += sampleSource(texUV - (float(i) * 2.0 - 0.6666666667) * aberration).r * weight;
        color.b += sampleSource(texUV + (float(i) * 2.0 - 0.6666666667) * aberration).b * weight;
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
    vec2 flareStep = textureScale / 300.0;
    flare += flareSample(texUV, vec2(flareStep.x * 0.5, 0.0), 0.98465018) * 2.0;
    flare += flareSample(texUV, vec2(flareStep.x * 1.5, 0.0), 0.98465018) * 0.8571428571;
    flare += flareSample(texUV, vec2(flareStep.x * 2.9666666667, 0.0), 0.98465018) * 1.4285714286;
    flare += flareSample(texUV, vec2(flareStep.x * 4.9545454545, 0.0), 0.98465018) * 1.0476190476;
    flare += flareSample(texUV, vec2(flareStep.x * 6.9285714286, 0.0), 0.98465018) * 0.6666666667;
    flare += flareSample(texUV, vec2(flareStep.x * 8.8333333333, 0.0), 0.98465018) * 0.2857142857;
    flare += flareSample(texUV, vec2(0.0, flareStep.y * 0.7337398374), 0.99845431) * 0.4392857143;
    flare += flareSample(texUV, vec2(0.0, flareStep.y * 2.7177419355), 0.99845431) * 0.2214285714;
    flare += flareSample(texUV, vec2(0.0, flareStep.y * 4.7065217391), 0.99845431) * 0.1642857143;
    color += flare * vec3(0.55, 0.25, 1.0) * 0.055;
    color *= vec3(0.9744, 0.9552, 1.032);
    gl_FragColor = vec4(mix(original.rgb, color, strength), original.a);
}
