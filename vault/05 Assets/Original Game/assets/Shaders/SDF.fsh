#extension GL_OES_standard_derivatives : enable

precision mediump float;

uniform lowp sampler2D texture0;
varying vec2 frag_uv;
varying lowp vec4 frag_diffuse;

// 0 is alpha-test
// 1/16 : 0.0625 - good when scaled up quite a lot
// 1/8 : 0.125 - good when scaled up a bit
// 1/4 : 0.25 
// <= 1/2 : 0.5 is just like a normal alpha blend

const float smoothing = 0.4;
float aastep( float threshold, float distance ) 
{
//#ifdef GL_OES_standard_derivatives
	float d  = (distance - 0.5); // distance rebias 0..1 --> -0.5 .. +0.5
	float aa = 0.75*length( vec2( dFdx( d ), dFdy( d ))); // anti-alias
	return smoothstep( -aa, aa, d );
//#else
	//const float w = 0.4; // fallback to smoothstep( 0.25, 0.75, distance ) if texture gradients not available
	//return smoothstep( threshold-w, threshold+w, distance ); 
//#endif
}

void main()
{
	float distance = texture2D(texture0, frag_uv).r;
	//float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);//*frag_diffuse.a;
	float alpha = aastep(0.5, distance);
	gl_FragColor = frag_diffuse*alpha;
}

/*
float contour(in float d, in float w)
{
	return smoothstep(0.5 - w, 0.5 + w, d);
}

float samp(in vec2 uv, float w)
{
	return contour(texture2D(texture0, uv).a, w);
}

void main(void)
{
	vec2 uv = gl_TexCoord[0].xy;
	float dist = texture2D(texture0, frag_uv).a;
	float width = fwidth(dist);

	float alpha = contour(dist, width);

	// ------- (comment this block out to get your original behavior)
	// Supersample, 4 extra points
	float dscale = 0.354; // half of 1/sqrt2; you can play with this
	vec2 duv = dscale * (dFdx(uv) + dFdy(uv));
	vec4 box = vec4(uv-duv, uv+duv);

	float asum = samp(box.xy, width)
	+ samp(box.zw, width)
	+ samp(box.xw, width)
	+ samp(box.zy, width);

	// weighted average, with 4 extra points having 0.5 weight each,
	// so 1 + 0.5*4 = 3 is the divisor
	alpha = (alpha + 0.5 * asum) / 3.;
	// -------

	gl_FragColor = frag_diffuse*alpha;
}*/
