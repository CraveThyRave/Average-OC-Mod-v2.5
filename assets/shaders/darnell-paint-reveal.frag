#pragma header

uniform float u_progress;
uniform float u_seed;

float paintHash(float value)
{
    return fract(sin(value * 12.9898 + u_seed * 7.233) * 43758.5453);
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    vec4 color = flixel_texture2D(bitmap, uv);
    if (u_progress >= 0.999)
    {
        gl_FragColor = color;
        return;
    }
    vec2 point = uv - vec2(0.5);
    float mask = 0.0;

    for (int index = 0; index < 28; index++)
    {
        float lineIndex = float(index);
        float key = lineIndex * 19.731 + 3.17;
        float orientation = floor(paintHash(key) * 6.0);
        float angle = 0.0;
        if (orientation == 1.0) angle = 1.5707963;
        else if (orientation == 2.0) angle = 0.7853982;
        else if (orientation == 3.0) angle = -0.7853982;
        else if (orientation == 4.0) angle = 0.4636476;
        else if (orientation == 5.0) angle = 1.1071487;

        vec2 direction = vec2(cos(angle), sin(angle));
        vec2 normal = vec2(-direction.y, direction.x);
        float linePosition = mix(-0.68, 0.68, paintHash(key + 1.7));
        float along = (dot(point, direction) + 0.72) / 1.44;
        if (paintHash(key + 4.9) > 0.5) along = 1.0 - along;
        float bend = sin(along * mix(8.0, 23.0, paintHash(key + 8.1))
            + paintHash(key + 9.6) * 6.2831853) * mix(0.002, 0.018, paintHash(key + 11.2));
        float distanceFromLine = abs(dot(point, normal) - linePosition + bend);
        float thickness = mix(0.025, 0.105, paintHash(key + 2.8));
        float lineStart = mix(0.0, 0.72, paintHash(key + 6.4));
        float lineDuration = mix(0.14, 0.62, paintHash(key + 7.5));
        float lineProgress = clamp((u_progress - lineStart) / lineDuration, 0.0, 1.0);
        float body = 1.0 - smoothstep(thickness * 0.58, thickness, distanceFromLine);
        float front = 1.0 - smoothstep(lineProgress - 0.025, lineProgress + 0.035, along);
        float stroke = body * front * step(0.001, lineProgress);
        mask = max(mask, stroke);
    }

    if (u_progress >= 0.999) mask = 1.0;
    gl_FragColor = color * mask;
}
