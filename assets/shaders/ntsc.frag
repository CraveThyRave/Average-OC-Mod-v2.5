#pragma header
#pragma format R8G8B8A8_SRGB

uniform int uFrame;
uniform float uInterlace;
uniform float effectStrength;
uniform vec4 effectArea;
uniform vec2 effectTextureSize;
uniform vec2 effectTextureOffset;

vec4 sampleSource(vec2 uv)
{
    vec2 size = effectTextureSize.x > 0.0 ? effectTextureSize : openfl_TextureSize;
    return texture2D(bitmap, (uv * size - effectTextureOffset) / openfl_TextureSize);
}

void main()
{
    vec2 sourceSize = effectTextureSize.x > 0.0 ? effectTextureSize : openfl_TextureSize;
    vec2 uv = (openfl_TextureCoordv * openfl_TextureSize + effectTextureOffset) / sourceSize;
    vec4 original = sampleSource(uv);
    vec2 pixelPosition = uv * sourceSize;
    if(effectArea.z > effectArea.x && (pixelPosition.x < effectArea.x || pixelPosition.y < effectArea.y || pixelPosition.x > effectArea.z || pixelPosition.y > effectArea.w)) { gl_FragColor = original; return; }
    if(effectStrength <= 0.0001) { gl_FragColor = original; return; }
    if(original.a == 0.0) { gl_FragColor = vec4(0.0); return; }
    float pixel = 1.0 / sourceSize.x;
    vec2 center = uv - vec2(0.5 * pixel, 0.0);
    float phase = 1.0 - 2.0 * mod(floor(uv.x * sourceSize.x) + floor(uv.y * sourceSize.y) + float(uFrame), 2.0);
    vec3 luma = vec3(0.2989, 0.5870, 0.1140);
    vec3 modulation = uInterlace == 1.0 ? phase * vec3(0.2115, -0.5229, 0.3114) : vec3(0.0);
    vec3 even = luma + modulation;
    vec3 odd = luma - modulation;
    float signal = 0.0;
    signal += dot(sampleSource(center + vec2(-26.6733096673 * pixel, 0.0)).rgb, even) * -0.0020839980;
    signal += dot(sampleSource(center + vec2(-26.0602990270 * pixel, 0.0)).rgb, odd) * -0.0020177440;
    signal += dot(sampleSource(center + vec2(-19.7818807096 * pixel, 0.0)).rgb, even) * 0.0030124800;
    signal += dot(sampleSource(center + vec2(-19.8958241215 * pixel, 0.0)).rgb, odd) * 0.0030078940;
    signal += dot(sampleSource(center + vec2(-16.0000000000 * pixel, 0.0)).rgb, even) * 0.0005068040;
    signal += dot(sampleSource(center + vec2(-15.0000000000 * pixel, 0.0)).rgb, odd) * 0.0026789220;
    signal += dot(sampleSource(center + vec2(-14.0000000000 * pixel, 0.0)).rgb, even) * 0.0058659440;
    signal += dot(sampleSource(center + vec2(-13.0000000000 * pixel, 0.0)).rgb, odd) * 0.0079669700;
    signal += dot(sampleSource(center + vec2(-12.0000000000 * pixel, 0.0)).rgb, even) * 0.0060533660;
    signal += dot(sampleSource(center + vec2(-11.0000000000 * pixel, 0.0)).rgb, odd) * -0.0022041120;
    signal += dot(sampleSource(center + vec2(-10.0000000000 * pixel, 0.0)).rgb, even) * -0.0167460520;
    signal += dot(sampleSource(center + vec2(-9.0000000000 * pixel, 0.0)).rgb, odd) * -0.0337954000;
    signal += dot(sampleSource(center + vec2(-8.0000000000 * pixel, 0.0)).rgb, even) * -0.0458289600;
    signal += dot(sampleSource(center + vec2(-7.0000000000 * pixel, 0.0)).rgb, odd) * -0.0432846940;
    signal += dot(sampleSource(center + vec2(-6.0000000000 * pixel, 0.0)).rgb, even) * -0.0177265460;
    signal += dot(sampleSource(center + vec2(-5.0000000000 * pixel, 0.0)).rgb, odd) * 0.0345439140;
    signal += dot(sampleSource(center + vec2(-4.0000000000 * pixel, 0.0)).rgb, even) * 0.1098438400;
    signal += dot(sampleSource(center + vec2(-3.0000000000 * pixel, 0.0)).rgb, odd) * 0.1966851580;
    signal += dot(sampleSource(center + vec2(-2.0000000000 * pixel, 0.0)).rgb, even) * 0.2780885620;
    signal += dot(sampleSource(center + vec2(-1.0000000000 * pixel, 0.0)).rgb, odd) * 0.3361116640;
    signal += dot(sampleSource(center + vec2(0.0000000000 * pixel, 0.0)).rgb, even) * 0.1785714290;
    float scale = clamp(max(signal, 0.0) / max(dot(original.rgb, luma), 0.001), 0.0, 2.0);
    vec3 color = clamp(original.rgb * scale, 0.0, 1.0);
    gl_FragColor = vec4(mix(original.rgb, color, clamp(effectStrength, 0.0, 1.0)), original.a);
}
