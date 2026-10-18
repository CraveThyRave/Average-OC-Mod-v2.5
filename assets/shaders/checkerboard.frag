
#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main
#define time iTime

void mainImage()
{

    vec2 coord = mod(floor(fragCoord + iTime * 0.24 * iResolution), iResolution);
    vec4 source = texture(iChannel0, coord / iResolution);
    fragColor = vec4(vec3(source.r), 1.0) * source + source;
}
