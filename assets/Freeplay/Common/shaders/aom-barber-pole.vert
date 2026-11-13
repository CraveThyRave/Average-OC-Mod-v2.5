#pragma header

attribute float alpha;
attribute vec4 colorMultiplier;
attribute vec4 colorOffset;
uniform bool hasColorTransform;
varying vec2 hudPosition;

void main()
{
    #pragma body
    hudPosition = vec2(openfl_Position.x, 720.0 - openfl_Position.y);
    openfl_Alphav = openfl_Alpha * alpha;
    if (hasColorTransform)
    {
        openfl_ColorOffsetv = colorOffset / 255.0;
        openfl_ColorMultiplierv = colorMultiplier;
    }
}
