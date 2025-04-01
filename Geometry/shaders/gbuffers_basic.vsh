#version 330 compatibility

out vec2 vLmCoord;
out vec4 vGlColor;

#include "common/common_vert.glsl"

void main() {
	gl_Position = ftransform();
	vLmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vGlColor = gl_Color;

	VERT_COMMON();
}