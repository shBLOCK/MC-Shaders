#version 330 compatibility

out vec2 lmcoord;
out vec4 glcolor;

#include "common_vert.glsl"

void main() {
	gl_Position = ftransform();
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	VERT_COMMON();
}