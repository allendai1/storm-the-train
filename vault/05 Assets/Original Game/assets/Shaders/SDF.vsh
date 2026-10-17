uniform mat4 mvpMat;

attribute vec3 pos0;
attribute vec2 uv0;
attribute lowp vec4 col0;

varying vec2 frag_uv;
varying lowp vec4 frag_diffuse;
 
void main()
{
	gl_Position = mvpMat * vec4(pos0, 1.0);
	frag_uv = uv0;
	frag_diffuse = col0;
}
