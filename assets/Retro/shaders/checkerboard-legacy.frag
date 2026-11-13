
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

    const float timeMulti = 0.2;

    const float xSpeed = 1.2;
    const float ySpeed = 1.2;

    float time = iTime * timeMulti;

    float xCoord = floor(fragCoord.x + time * xSpeed * iResolution.x);
    float yCoord = floor(fragCoord.y + time * ySpeed * iResolution.y);

    vec2 coord = vec2(xCoord, yCoord);
    coord = mod(coord, iResolution.xy);

	vec2 uv = coord/iResolution.xy;

    float col = texture(iChannel0, uv).x;

    vec3 color = vec3(col);

    fragColor = vec4(color,1.0) * texture(iChannel0, uv) + texture(iChannel0, uv);
}
