uniform mat4 mvpMat;
uniform lowp sampler2D texture;

attribute vec3 pos0;
attribute vec2 uv0;

varying vec2 frag_uv;
 
void main()
{
	gl_Position = mvpMat * vec4(pos0, 1.0);
	frag_uv = uv0;
}
