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
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    vec4 camera = texture(iChannel0,uv);
    vec3 col = 1.0 - camera.xyz;

    // Output to screen
    // Flixel uses premultiplied alpha. Multiplying the inverted RGB by alpha
    // prevents transparent atlas pixels from contributing white color.
    fragColor = vec4(col * camera.a, camera.a);
}

// https://www.shadertoy.com/view/dssXRl
