#pragma header

// Dark diagonal bands sampled from the fill itself, so this remains a darker
// version of whichever icon colour the bar currently uses.
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

    // Treat the source artwork's alpha as the hard mask for every effect.
    // This prevents the diagonal edge from appearing in transparent padding.
    if (color.a <= 0.001)
        discard;

    // Flixel supplies a premultiplied sample. Work in straight RGB while
    // generating the pole colours, then premultiply the result again below so
    // HUD and sprite alpha fades affect the bands exactly like the base fill.
    float sourceAlpha = color.a;
    color.rgb /= sourceAlpha;
    float leftEdge = 42.0 / 1940.0;
    float rightEdge = 1901.0 / 1940.0;
    float topEdge = 84.0 / 234.0;
    float bottomEdge = 194.0 / 234.0;
    float yAcrossBar = clamp((uv.y - topEdge) / (bottomEdge - topEdge), 0.0, 1.0);

    // The player uses the same full bar-fill art as the opponent. Reveal it
    // continuously from right to left, with a diagonal leading edge. These
    // bounds match bar-fill.png's opaque area inside its 1940x234 canvas.
    if (u_playerMask > 0.5)
    {
        float across = u_fillMax > u_fillMin ? mix(u_fillMax, u_fillMin, clamp(u_fill, 0.0, 1.0)) : 1.0 - clamp(u_fill, 0.0, 1.0);
        float cut = mix(leftEdge, rightEdge, across);

        // Keep exact zero completely empty and exact full completely filled.
        if (u_fill <= 0.0001)
            discard;
        if (u_fill < 0.9999)
        {
            // Push the top farther left and the bottom farther right for a
            // sharper, more forcefully left-leaning player edge.
            cut += (yAcrossBar - 0.5) * 0.055;
            if (uv.x < cut)
                discard;

            // Draw the divider directly on the cut so it follows the diagonal.
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

    // Screen-space coordinates keep the bands continuous across the full
    // opponent and player fills.
    // At 50% tilt is zero, making the bands stand vertically. Positive and
    // negative health offsets rotate them smoothly in opposite directions.
    float diagonal = fract((gl_FragCoord.x + gl_FragCoord.y * u_tilt) * 0.04
        + u_scroll);
    float band = smoothstep(0.02, 0.045, diagonal)
        * (1.0 - smoothstep(0.13, 0.16, diagonal));
    vec3 opponentPole = color.rgb * 0.52;
    vec3 poleColor = u_playerMask > 0.5 ? color.rgb * 0.68 : opponentPole;
    color.rgb = mix(color.rgb, poleColor, band * (1.0 - whiteEdge));
    gl_FragColor = vec4(color.rgb * sourceAlpha, sourceAlpha);
}
