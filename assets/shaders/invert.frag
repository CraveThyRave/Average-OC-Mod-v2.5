#pragma header
vec2 uv = openfl_TextureCoordv.xy;
vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
vec2 iResolution = openfl_TextureSize;
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D
#define fragColor gl_FragColor
#define mainImage main

void mainImage()
{

    vec2 uv = fragCoord/iResolution.xy;

    vec4 camera = texture(iChannel0,uv);
    vec3 col = 1.0 - camera.xyz;

    fragColor = vec4(col * camera.a, camera.a);
}

