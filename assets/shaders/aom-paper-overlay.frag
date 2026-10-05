#pragma header

uniform sampler2D u_paper;
uniform float u_strength;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 source = flixel_texture2D(bitmap, uv);
    if (source.a <= 0.001)
        discard;

    float sourceAlpha = source.a;
    vec3 straightColor = source.rgb / sourceAlpha;

    // BG.png is a 2x3 atlas of 2560x1440 paper frames. Sampling in screen
    // space keeps the folds continuous across the separately drawn outline,
    // inline, fills, bands, and divider.
    vec2 paperFrameUV = vec2(
        fract(gl_FragCoord.x / 1280.0) * 0.5,
        fract(gl_FragCoord.y / 720.0) / 3.0
    );
    vec3 paper = texture2D(u_paper, paperFrameUV).rgb;
    float paperLuma = dot(paper, vec3(0.299, 0.587, 0.114));
    float paperShade = clamp(1.0 + (paperLuma - 0.90) * 2.8, 0.58, 1.16);
    straightColor *= mix(1.0, paperShade, clamp(u_strength, 0.0, 1.0));

    gl_FragColor = vec4(straightColor * sourceAlpha, sourceAlpha);
}
