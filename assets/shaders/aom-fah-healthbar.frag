#pragma header

uniform float u_fill;
uniform float u_flatten;
uniform float u_fillMin;
uniform float u_fillMax;
uniform float u_scroll;
uniform float u_tilt;
uniform float u_visibleLeft;
uniform float u_visibleRight;
uniform float u_visibleTop;
uniform float u_visibleBottom;
uniform vec3 u_dadColor;
uniform vec3 u_bfColor;
uniform float u_whiteDadTop;
uniform float u_flipY;
uniform float u_textureShading;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 rawSource = texture2D(bitmap, uv);
    vec4 source = flixel_texture2D(bitmap, uv);
    if (source.a <= 0.001)
        discard;

    float fill = clamp(u_fill, 0.0, 1.0);
    float xAcross = clamp((uv.x - u_visibleLeft)
        / (u_visibleRight - u_visibleLeft), 0.0, 1.0);
    float cut = u_fillMax > u_fillMin ? mix(u_fillMax, u_fillMin, fill) : 1.0 - fill;
    if (fill > 0.0001 && fill < 0.9999)
        cut += (0.5 - (1.0 - clamp((uv.y - u_visibleTop)
            / (u_visibleBottom - u_visibleTop), 0.0, 1.0)) * (1.0 - u_flatten)) * 0.115;

    float playerSide = fill <= 0.0001 ? 0.0 : (fill >= 0.9999 ? 1.0 : step(cut, xAcross));
    vec3 barColor = mix(u_dadColor, u_bfColor, playerSide);

    // The replacement atlas contains its own animated paper folds. Sample the
    // un-tinted bitmap so character colour transforms cannot flatten or skew
    // that shading, then apply it only to the standard Fah fill. Week 6 keeps
    // its separate clean Senpai/Roses artwork.
    float textureLuma = dot(rawSource.rgb, vec3(0.299, 0.587, 0.114));
    barColor *= mix(1.0, clamp(textureLuma, 0.55, 1.0),
        clamp(u_textureShading, 0.0, 1.0));

    // Spookeez keeps the visually upper stripe of the opponent portion white.
    // Account for the sprite's vertical flip so "top" remains screen-relative
    // in both scroll directions.
    float visibleMiddleY = (u_visibleTop + u_visibleBottom) * 0.5;
    float textureTop = 1.0 - step(visibleMiddleY, uv.y);
    float visualTop = mix(textureTop, 1.0 - textureTop, u_flipY);
    float whiteOpponentTop = u_whiteDadTop * visualTop * (1.0 - playerSide);
    barColor = mix(barColor, vec3(1.0), whiteOpponentTop);

    float diagonal = fract((gl_FragCoord.x + gl_FragCoord.y * u_tilt) * 0.04
        + u_scroll);
    float band = smoothstep(0.02, 0.045, diagonal)
        * (1.0 - smoothstep(0.13, 0.16, diagonal));
    barColor *= mix(1.0, 0.68, band);

    // The white boundary is part of the bar shader, so the source fill's alpha
    // clips it to visible pixels and the animated outline remains above it.
    if (fill > 0.0001 && fill < 0.9999)
    {
        float whiteEdge = (1.0 - smoothstep(0.0035, 0.007, xAcross - cut))
            * step(cut, xAcross) * smoothstep(0.08, 0.35, source.a);
        barColor = mix(barColor, vec3(1.0), whiteEdge);
    }

    // flixel_texture2D includes the sprite and camera fade in source.a and the
    // renderer expects premultiplied output. Keep the generated colours and
    // barber-pole bands on that same fade instead of returning full-strength
    // RGB with only a reduced alpha.
    gl_FragColor = vec4(barColor * source.a, source.a);
}
