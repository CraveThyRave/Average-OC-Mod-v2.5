#pragma header

uniform float strength;

void main()
{
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv.xy);

    vec3 inverted = 1.0 - color.rgb;

    color.rgb = mix(color.rgb, inverted, strength);

    gl_FragColor = color;
}
