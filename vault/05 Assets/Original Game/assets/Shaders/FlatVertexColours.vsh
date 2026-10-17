uniform mat4 mvpMat;
 
attribute vec3 pos0;
attribute lowp vec4 col0;

varying lowp vec4 frag_diffuse;
 
void main()
{
	gl_PointSize = 5.0;
	gl_Position = mvpMat * vec4(pos0, 1.0);
	frag_diffuse = col0;
}
