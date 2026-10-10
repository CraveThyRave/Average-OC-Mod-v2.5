#pragma header

#define V vec2(0.,1.)
#define PI 3.14159265
#define HUGE 1E9
#define VHSRES vec2(320.0,240.0)
#define saturate(i) clamp(i,0.,1.)
#define lofi(i,d) floor(i/d)*d
#define SIDE_INSET (4.0 / openfl_TextureSize.x)
#define validuv(v) (abs(v.x-0.5)<0.5-SIDE_INSET&&abs(v.y-0.5)<0.5)
#define SAMPLES 3

uniform float aberration;
uniform float effectTime;
uniform float noiseTime;
uniform float effectStrength;
uniform float visibility;
uniform sampler2D noiseTexture;

vec3 tex2D(sampler2D _tex,vec2 _p)
{
    vec3 col=texture2D(_tex,_p).xyz;
    if(.5<abs(_p.x-.5)){
        col=vec3(.1);
    }
    return col;
}

float noise(vec2 p)
{
	float s = texture2D(noiseTexture,fract(vec2(1.,2.*cos(noiseTime))*noiseTime*8. + p)).x;
	s *= s;
	return s;
}

vec2 screenDistort(vec2 uv)
{
	uv -= vec2(.5,.5);
	uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
	uv += vec2(.5,.5);
	return uv;
}

float v2random( vec2 uv ) {
  return texture2D( noiseTexture, mod( uv, vec2( 1.0 ) ) ).x;
}

mat2 rotate2D( float t ) {
  return mat2( cos( t ), sin( t ), -sin( t ), cos( t ) );
}

vec3 rgb2yiq( vec3 rgb ) {
  return mat3( 0.299, 0.596, 0.211, 0.587, -0.274, -0.523, 0.114, -0.322, 0.312 ) * rgb;
}

vec3 yiq2rgb( vec3 yiq ) {
  return mat3( 1.000, 1.000, 1.000, 0.956, -0.272, -1.106, 0.621, -0.647, 1.703 ) * yiq;
}

vec3 vhsTex2D( vec2 uv, float rot ) {
  if ( validuv( uv ) ) {
    vec3 yiq = vec3( 0.0 );
    for ( int i = 0; i < SAMPLES; i ++ ) {
      vec2 sampleUV = uv - vec2( float( i ), 0.0 ) / VHSRES;
      float sampleInset = SIDE_INSET + 0.5 / openfl_TextureSize.x;
      sampleUV.x = clamp(sampleUV.x, sampleInset, 1.0 - sampleInset);
      yiq += (
        rgb2yiq( texture2D( bitmap, sampleUV ).xyz ) *
        vec2( float( i ), float( SAMPLES - 1 - i ) ).yxx / float( SAMPLES - 1 )
      ) / float( SAMPLES ) * 2.0;
    }
    if ( rot != 0.0 ) { yiq.yz = rotate2D( rot ) * yiq.yz; }
    return yiq2rgb( yiq );
  }
  return vec3( 0.1, 0.1, 0.1 );
}

void main() {
    vec2 uv = (openfl_TextureCoordv * openfl_TextureSize - vec2(2.0)) / (openfl_TextureSize - vec2(4.0));
    vec2 ndcPos = uv * 2.0 - 1.0;
    float aspect = openfl_TextureSize.x / openfl_TextureSize.y;

    float u_angle = -2.4 * sin(effectTime * 2.0);

    float eye_angle = abs(u_angle);
    float half_angle = max(eye_angle/2.0, 0.0001);
    float half_dist = tan(half_angle);

    vec2  vp_scale = vec2(aspect, 1.0);
    vec2  P = ndcPos * vp_scale;

    float vp_dia = length(vp_scale);
    vec2 rel_P = P / max(length(P), 0.0001) / normalize(vp_scale);

    vec2 pos_prj = ndcPos;

    float beta = abs(atan((length(P) / vp_dia) * half_dist) * -abs(cos(effectTime - 0.25 + 0.5)));
    pos_prj = rel_P * beta / half_angle;

    vec2 uv_prj = (pos_prj * 0.5 + 0.5);

    vec2 trueAberration = aberration * effectStrength * pow((uv_prj.st - 0.5), vec2(3.0, 3.0));

    vec2  uvn = screenDistort(uv_prj.st);
    vec3  col = vec3( 0.0, 0.0, 0.0 );

    uvn.x += ( v2random( vec2( uvn.y / 10.0, noiseTime / 10.0 ) / 1.0 ) - 0.5 ) / VHSRES.x * effectStrength;
    uvn.x += ( v2random( vec2( uvn.y, noiseTime * 10.0 ) ) - 0.5 ) / VHSRES.x * effectStrength;

    float tcPhase = smoothstep( 0.9, 0.96, sin( uvn.y * 8.0 - ( noiseTime + 0.14 * v2random( noiseTime * vec2( 0.67, 0.59 ) ) ) * PI * 1.2 ) );
    float tcNoise = smoothstep( 0.3, 1.0, v2random( vec2( uvn.y * 4.77, noiseTime ) ) );
    float tc = tcPhase * tcNoise;
    uvn.x = uvn.x - tc / VHSRES.x * 8.0 * effectStrength;


    float snPhase = smoothstep( 6.0 / VHSRES.y, 0.0, uvn.y );
    uvn.x += snPhase * ( ( v2random( vec2( uv.y * 100.0, noiseTime * 10.0 ) ) - 0.5 ) / VHSRES.x * 24.0 ) * effectStrength;

	vec3 video = vec3(
        vhsTex2D(uvn + trueAberration, 0.0).r,
        vhsTex2D(uvn, 0.0).g,
        vhsTex2D(uvn - trueAberration, 0.0).b
    );
    vec3 clean = validuv(uvn) ? texture2D(bitmap, uvn).rgb : vec3(0.1);
    video = mix(clean, video, effectStrength);
	float vigAmt = 3.+.3*sin( noiseTime + 1.*cos( noiseTime*5.));
	float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));


	video += noise(uvn*5.)/5. * effectStrength;
	video *= validuv(uvn) ? mix(1.0, vignette, effectStrength) : vignette;
	video *= mix(1.0, (12.+mod(uvn.y*30.+ noiseTime,1.))/13., effectStrength);

	gl_FragColor = vec4(video * visibility, 1.0);
}
