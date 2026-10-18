#pragma header

uniform float u_scroll;
uniform float u_tilt;
uniform float u_playerMask;
uniform float u_fill;
uniform float u_fillMin;
uniform float u_fillMax;
uniform vec3 u_dadColor;
uniform vec3 u_gfColor;
uniform float u_splitPosition;
uniform float u_flipY;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 color = flixel_texture2D(bitmap, uv);
    float whiteEdge = 0.0;

    if (color.a <= 0.001)
        discard;

    float sourceAlpha = color.a;
    color.rgb /= sourceAlpha;
    float leftEdge = 42.0 / 1940.0;
    float rightEdge = 1901.0 / 1940.0;
    float topEdge = 84.0 / 234.0;
    float bottomEdge = 194.0 / 234.0;
    float yAcrossBar = clamp((uv.y - topEdge) / (bottomEdge - topEdge), 0.0, 1.0);

    if (u_playerMask > 0.5)
    {
        float across = u_fillMax > u_fillMin ? mix(u_fillMax, u_fillMin, clamp(u_fill, 0.0, 1.0)) : 1.0 - clamp(u_fill, 0.0, 1.0);
        float cut = mix(leftEdge, rightEdge, across);

        if (u_fill <= 0.0001)
            discard;
        if (u_fill < 0.9999)
        {

            cut += (yAcrossBar - 0.5) * 0.055;
            if (uv.x < cut)
                discard;

            whiteEdge = (1.0 - smoothstep(0.0035, 0.0065, uv.x - cut))
                * smoothstep(0.08, 0.35, color.a);
            color.rgb = mix(color.rgb, vec3(1.0), whiteEdge);
        }
    }
    else
    {
        float sourceLuma = clamp(dot(color.rgb, vec3(0.299, 0.587, 0.114)), 0.35, 1.0);
        float visualY = mix(yAcrossBar, 1.0 - yAcrossBar, u_flipY);
        float splitPosition = clamp(u_splitPosition, 0.0, 1.0);
        color.rgb = mix(u_gfColor, u_dadColor, step(splitPosition, visualY)) * sourceLuma;
        float interior = step(0.001, splitPosition) * (1.0 - step(0.999, splitPosition));
        float line = (1.0 - smoothstep(0.0, 0.022, abs(visualY - splitPosition))) * interior;
        color.rgb = mix(color.rgb, vec3(1.0), line);
    }

    float diagonal = fract((gl_FragCoord.x + gl_FragCoord.y * u_tilt) * 0.04
        + u_scroll);
    float band = smoothstep(0.02, 0.045, diagonal)
        * (1.0 - smoothstep(0.13, 0.16, diagonal));
    vec3 opponentPole = color.rgb * 0.52;
    vec3 poleColor = u_playerMask > 0.5 ? color.rgb * 0.68 : opponentPole;
    color.rgb = mix(color.rgb, poleColor, band * (1.0 - whiteEdge));
    gl_FragColor = vec4(color.rgb * sourceAlpha, sourceAlpha);
}
