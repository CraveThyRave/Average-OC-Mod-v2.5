//SHADERTOY PORT FIX
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
//SHADERTOY PORT FIX

// https://www.shadertoy.com/view/WtGGRt

void mainImage()
{
    // Algebraically identical to the original shader, but sample the texture
    // once instead of three times for every screen pixel.
    vec2 coord = mod(floor(fragCoord + iTime * 0.24 * iResolution), iResolution);
    vec4 source = texture(iChannel0, coord / iResolution);
    fragColor = vec4(vec3(source.r), 1.0) * source + source;
}
