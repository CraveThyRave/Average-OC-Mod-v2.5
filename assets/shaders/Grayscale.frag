#pragma header

uniform float desaturationAmount;

void main() {
    vec4 sourceColor = texture2D(bitmap, openfl_TextureCoordv);
    float luminance = dot(sourceColor.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 grayscale = vec3(luminance);
    gl_FragColor = vec4(mix(grayscale, sourceColor.rgb, desaturationAmount), sourceColor.a);
}
