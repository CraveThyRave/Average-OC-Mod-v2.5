#pragma header
#pragma format R8G8B8A8_SRGB

uniform int uFrame;
uniform float uInterlace;
uniform float effectStrength;

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 original = flixel_texture2D(bitmap, uv);
    if(effectStrength <= 0.0001) { gl_FragColor = original; return; }
    float pixel = 1.0 / openfl_TextureSize.x;
    vec2 center = uv - vec2(0.5 * pixel, 0.0);
    float phase = 3.14159265 * (mod(uv.y * openfl_TextureSize.y, 2.0) + float(uFrame) + center.x * openfl_TextureSize.x);
    vec3 luma = vec3(0.2989, 0.5870, 0.1140);
    vec3 modulation = uInterlace == 1.0 ? cos(phase) * vec3(0.5959, -0.2744, -0.3216) + sin(phase) * vec3(0.2115, -0.5229, 0.3114) : vec3(0.0);
    vec3 even = luma + modulation;
    vec3 odd = luma - modulation;
    float signal = 0.0;
    signal += dot(texture2D(bitmap, center + vec2(-32.0 * pixel, 0.0)).rgb, even) * -0.000349688;
    signal += dot(texture2D(bitmap, center + vec2(-31.0 * pixel, 0.0)).rgb, odd) * -0.000411688;
    signal += dot(texture2D(bitmap, center + vec2(-30.0 * pixel, 0.0)).rgb, even) * -0.000298906;
    signal += dot(texture2D(bitmap, center + vec2(-29.0 * pixel, 0.0)).rgb, odd) * -0.000103386;
    signal += dot(texture2D(bitmap, center + vec2(-27.0 * pixel, 0.0)).rgb, odd) * -0.000132342;
    signal += dot(texture2D(bitmap, center + vec2(-26.0 * pixel, 0.0)).rgb, even) * -0.000490116;
    signal += dot(texture2D(bitmap, center + vec2(-25.0 * pixel, 0.0)).rgb, odd) * -0.000865856;
    signal += dot(texture2D(bitmap, center + vec2(-24.0 * pixel, 0.0)).rgb, even) * -0.000945288;
    signal += dot(texture2D(bitmap, center + vec2(-23.0 * pixel, 0.0)).rgb, odd) * -0.000504472;
    signal += dot(texture2D(bitmap, center + vec2(-22.0 * pixel, 0.0)).rgb, even) * 0.000397858;
    signal += dot(texture2D(bitmap, center + vec2(-21.0 * pixel, 0.0)).rgb, odd) * 0.001374116;
    signal += dot(texture2D(bitmap, center + vec2(-20.0 * pixel, 0.0)).rgb, even) * 0.001888224;
    signal += dot(texture2D(bitmap, center + vec2(-19.0 * pixel, 0.0)).rgb, odd) * 0.001606934;
    signal += dot(texture2D(bitmap, center + vec2(-18.0 * pixel, 0.0)).rgb, even) * 0.000726398;
    signal += dot(texture2D(bitmap, center + vec2(-17.0 * pixel, 0.0)).rgb, odd) * 0.000026844;
    signal += dot(texture2D(bitmap, center + vec2(-16.0 * pixel, 0.0)).rgb, even) * 0.000506804;
    signal += dot(texture2D(bitmap, center + vec2(-15.0 * pixel, 0.0)).rgb, odd) * 0.002678922;
    signal += dot(texture2D(bitmap, center + vec2(-14.0 * pixel, 0.0)).rgb, even) * 0.005865944;
    signal += dot(texture2D(bitmap, center + vec2(-13.0 * pixel, 0.0)).rgb, odd) * 0.007966970;
    signal += dot(texture2D(bitmap, center + vec2(-12.0 * pixel, 0.0)).rgb, even) * 0.006053366;
    signal += dot(texture2D(bitmap, center + vec2(-11.0 * pixel, 0.0)).rgb, odd) * -0.002204112;
    signal += dot(texture2D(bitmap, center + vec2(-10.0 * pixel, 0.0)).rgb, even) * -0.016746052;
    signal += dot(texture2D(bitmap, center + vec2(-9.0 * pixel, 0.0)).rgb, odd) * -0.033795400;
    signal += dot(texture2D(bitmap, center + vec2(-8.0 * pixel, 0.0)).rgb, even) * -0.045828960;
    signal += dot(texture2D(bitmap, center + vec2(-7.0 * pixel, 0.0)).rgb, odd) * -0.043284694;
    signal += dot(texture2D(bitmap, center + vec2(-6.0 * pixel, 0.0)).rgb, even) * -0.017726546;
    signal += dot(texture2D(bitmap, center + vec2(-5.0 * pixel, 0.0)).rgb, odd) * 0.034543914;
    signal += dot(texture2D(bitmap, center + vec2(-4.0 * pixel, 0.0)).rgb, even) * 0.109843840;
    signal += dot(texture2D(bitmap, center + vec2(-3.0 * pixel, 0.0)).rgb, odd) * 0.196685158;
    signal += dot(texture2D(bitmap, center + vec2(-2.0 * pixel, 0.0)).rgb, even) * 0.278088562;
    signal += dot(texture2D(bitmap, center + vec2(-1.0 * pixel, 0.0)).rgb, odd) * 0.336111664;
    signal += dot(texture2D(bitmap, center + vec2(0.0 * pixel, 0.0)).rgb, even) * 0.178571429;
    float scale = clamp(max(signal, 0.0) / max(dot(original.rgb, luma), 0.001), 0.0, 2.0);
    vec3 color = clamp(original.rgb * scale, 0.0, 1.0);
    gl_FragColor = vec4(mix(original.rgb, color, clamp(effectStrength, 0.0, 1.0)), original.a);
}
