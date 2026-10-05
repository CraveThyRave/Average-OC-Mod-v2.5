//========================================================//
// NOLA PURPLE SHADER
// Psych Engine 0.6.3
//========================================================//

#pragma header

// Controlled by Lua.
//
// 0.0 = normal game
// 1.0 = full shader
uniform float effectStrength;


float NoiseSeed;


//========================================================//
// RANDOM
//========================================================//

float randomFloat()
{
	NoiseSeed = sin(NoiseSeed) * 84522.13219145687;
	return fract(NoiseSeed);
}


//========================================================//
// S CURVE
//========================================================//

float SCurve(float value, float amount, float correction)
{
	float curve = 1.0;

	if (value < 0.5)
	{
		curve =
			pow(value, amount) *
			pow(2.0, amount) *
			0.5;
	}
	else
	{
		curve =
			1.0 -
			pow(1.0 - value, amount) *
			pow(2.0, amount) *
			0.5;
	}

	return pow(curve, correction);
}


//========================================================//
// ACES TONEMAPPING
//========================================================//

vec3 ACESFilm(vec3 x)
{
	float a = 2.51;
	float b = 0.03;
	float c = 2.43;
	float d = 0.59;
	float e = 0.14;

	return
		(x * (a * x + b)) /
		(x * (c * x + d) + e);
}


//========================================================//
// CHROMATIC ABERRATION
//========================================================//

vec3 chromaticAbberation(
	sampler2D tex,
	vec2 uv,
	float amount
)
{
	float aberrationAmount =
		amount / 10.0;

	vec2 distFromCenter =
		uv - 0.5;

	vec2 aberrated =
		aberrationAmount *
		pow(
			distFromCenter,
			vec2(3.0, 3.0)
		);

	vec3 color =
		vec3(0.0);


	for (int i = 1; i <= 8; i++)
	{
		float weight =
			1.0 /
			pow(
				2.0,
				float(i)
			);

		color.r +=
			flixel_texture2D(
				tex,
				uv - float(i) * aberrated
			).r *
			weight;


		color.b +=
			flixel_texture2D(
				tex,
				uv + float(i) * aberrated
			).b *
			weight;
	}


	color.g =
		flixel_texture2D(
			tex,
			uv
		).g *
		0.9961;


	return color;
}


//========================================================//
// FILM GRAIN
//========================================================//

vec3 filmGrain()
{
	// Original was:
	//
	// 0.9 + randomFloat() * 0.15
	//
	// Much softer now.
	return vec3(
		0.97 +
		randomFloat() * 0.05
	);
}


//========================================================//
// CONTRAST
//========================================================//

vec3 contrast(vec3 color)
{
	// Softer than the original contrast curve.
	return vec3(
		SCurve(color.r, 2.1, 1.0),
		SCurve(color.g, 2.3, 0.85),
		SCurve(color.b, 2.0, 0.8)
	);
}


//========================================================//
// FLARES
//========================================================//

vec3 flares(
	sampler2D tex,
	vec2 uv,
	float threshold,
	float intensity,
	float stretch,
	float brightness
)
{
	threshold =
		1.0 - threshold;


	vec3 hdr =
		flixel_texture2D(
			tex,
			uv
		).rgb;


	hdr =
		vec3(
			floor(
				threshold +
				pow(hdr.r, 1.0)
			)
		);


	float d =
		intensity;

	float c =
		intensity * stretch;


	//====================================================//
	// HORIZONTAL
	//====================================================//

	for (float i = c; i > -1.0; i--)
	{
		float texL =
			flixel_texture2D(
				tex,
				uv + vec2(i / d, 0.0)
			).r;


		float texR =
			flixel_texture2D(
				tex,
				uv - vec2(i / d, 0.0)
			).r;


		hdr +=
			floor(
				threshold +
				pow(
					max(texL, texR),
					4.0
				)
			) *
			(1.0 - i / c);
	}


	//====================================================//
	// VERTICAL
	//====================================================//

	for (float i = c / 2.0; i > -1.0; i--)
	{
		float texU =
			flixel_texture2D(
				tex,
				uv + vec2(0.0, i / d)
			).r;


		float texD =
			flixel_texture2D(
				tex,
				uv - vec2(0.0, i / d)
			).r;


		hdr +=
			floor(
				threshold +
				pow(
					max(texU, texD),
					40.0
				)
			) *
			(1.0 - i / c) *
			0.15;
	}


	//====================================================//
	// PURPLE FLARE COLOR
	//====================================================//
	//
	// Original:
	//
	// vec3(1.0, 0.7, 0.2)
	//
	// That was the yellow/orange tint.
	//
	// This is violet/purple.
	//====================================================//

	hdr *= vec3(
		0.55,
		0.25,
		1.0
	);


	return
		hdr *
		brightness;
}


//========================================================//
// GLOW
//========================================================//

vec3 samplef(vec2 tc, vec3 color)
{
	return pow(
		color,
		vec3(
			2.2,
			2.2,
			2.2
		)
	);
}


vec3 highlights(
	vec3 pixel,
	float thres
)
{
	float val =
		(
			pixel.x +
			pixel.y +
			pixel.z
		) /
		3.0;


	return
		pixel *
		smoothstep(
			thres - 0.1,
			thres + 0.1,
			val
		);
}


vec3 hsample(
	vec3 color,
	vec2 tc
)
{
	return highlights(
		samplef(
			tc,
			color
		),
		0.68
	);
}


vec3 blur(
	vec3 col,
	vec2 tc,
	float offs
)
{
	vec4 xoffs =
		offs *
		vec4(
			-2.0,
			-1.0,
			1.0,
			2.0
		) /
		openfl_TextureSize.x;


	vec4 yoffs =
		offs *
		vec4(
			-2.0,
			-1.0,
			1.0,
			2.0
		) /
		openfl_TextureSize.y;


	vec3 color =
		vec3(0.0);


	color += hsample(col, tc + vec2(xoffs.x, yoffs.x)) * 0.00366;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.x)) * 0.01465;
	color += hsample(col, tc + vec2(0.0,     yoffs.x)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.x)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.x)) * 0.00366;


	color += hsample(col, tc + vec2(xoffs.x, yoffs.y)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.y)) * 0.05861;
	color += hsample(col, tc + vec2(0.0,     yoffs.y)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.y)) * 0.05861;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.y)) * 0.01465;


	color += hsample(col, tc + vec2(xoffs.x, 0.0)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.y, 0.0)) * 0.09524;
	color += hsample(col, tc + vec2(0.0,     0.0)) * 0.15018;
	color += hsample(col, tc + vec2(xoffs.z, 0.0)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.w, 0.0)) * 0.02564;


	color += hsample(col, tc + vec2(xoffs.x, yoffs.z)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.z)) * 0.05861;
	color += hsample(col, tc + vec2(0.0,     yoffs.z)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.z)) * 0.05861;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.z)) * 0.01465;


	color += hsample(col, tc + vec2(xoffs.x, yoffs.w)) * 0.00366;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.w)) * 0.01465;
	color += hsample(col, tc + vec2(0.0,     yoffs.w)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.w)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.w)) * 0.00366;


	return color;
}


vec3 glow(
	vec3 col,
	vec2 uv
)
{
	// Reduced blur radii compared to original.
	vec3 color =
		blur(col, uv, 2.0);


	color +=
		blur(col, uv, 3.0);


	color +=
		blur(col, uv, 5.0);


	color /= 3.0;


	color +=
		samplef(
			uv,
			col
		);


	return color;
}


//========================================================//
// MARGINS
//========================================================//

vec3 margins(
	vec3 color,
	vec2 uv,
	float marginSize
)
{
	if (
		uv.y < marginSize ||
		uv.y > 1.0 - marginSize
	)
	{
		return vec3(0.0);
	}

	return color;
}


//========================================================//
// MAIN
//========================================================//

void main()
{
	vec2 uv =
		openfl_TextureCoordv.xy;


	vec4 original =
		flixel_texture2D(
			bitmap,
			uv
		);


	float strength =
		clamp(
			effectStrength,
			0.0,
			1.0
		);


	//====================================================//
	// SHADER OFF
	//====================================================//

	if (strength <= 0.001)
	{
		gl_FragColor =
			original;

		return;
	}


	if (uv.y < 0.1 || uv.y > 0.9)
	{
		gl_FragColor = vec4(mix(original.rgb, vec3(0.0), strength), original.a);
		return;
	}

	vec3 color =
		original.rgb;


	//====================================================//
	// CHROMATIC ABERRATION
	//====================================================//
	//
	// Original = 0.6
	// New      = 0.22
	//====================================================//

	color =
		chromaticAbberation(
			bitmap,
			uv,
			0.22
		);


	//====================================================//
	// LIGHT FILM GRAIN
	//====================================================//

	color *=
		filmGrain();


	//====================================================//
	// TONEMAPPING
	//====================================================//

	vec3 mapped =
		ACESFilm(color);


	// Don't completely replace the original color with
	// the ACES result.
	color =
		mix(
			color,
			mapped,
			0.60
		);


	//====================================================//
	// SOFT GLOW
	//====================================================//
	//
	// Original:
	//
	// 0.1 + glow * 1.8
	//
	// New:
	//
	// much weaker glow
	//====================================================//

	vec3 glowColor =
		clamp(
			0.02 +
			glow(color, uv) *
			1.08,
			0.0,
			1.0
		);


	color =
		mix(
			color,
			glowColor,
			0.50
		);


	//====================================================//
	// SOFTER CONTRAST
	//====================================================//

	vec3 contrasted =
		contrast(color);


	color =
		mix(
			color,
			contrasted,
			0.45
		);


	//====================================================//
	// PURPLE FLARES
	//====================================================//
	//
	// Original brightness = 0.2
	// New brightness      = 0.055
	//====================================================//

	color +=
		flares(
			bitmap,
			uv,

			0.94,
			300.0,
			0.035,
			0.055
		);


	//====================================================//
	// VERY LIGHT PURPLE ATMOSPHERE
	//====================================================//

	vec3 purpleTint =
		color *
		vec3(
			0.92,
			0.86,
			1.10
		);


	color =
		mix(
			color,
			purpleTint,
			0.32
		);


	//====================================================//
	// LETTERBOX MARGINS
	//====================================================//

	color =
		margins(
			color,
			uv,
			0.1
		);


	//====================================================//
	// FINAL ACTIVATION EASE
	//====================================================//
	//
	// This is what lets your Lua smoothly transition:
	//
	// effectStrength = 0
	//     normal game
	//
	// effectStrength = 0.5
	//     halfway
	//
	// effectStrength = 1
	//     full effect
	//====================================================//

	vec3 finalColor =
		mix(
			original.rgb,
			color,
			strength
		);


	gl_FragColor =
		vec4(
			finalColor,
			original.a
		);
}
