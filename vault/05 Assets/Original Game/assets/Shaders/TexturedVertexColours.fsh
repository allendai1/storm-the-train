precision mediump float;

uniform lowp sampler2D texture0;
varying vec2 frag_uv;
varying lowp vec4 frag_diffuse;

void main()
{
	gl_FragColor = texture2D(texture0, frag_uv)*frag_diffuse;
}
