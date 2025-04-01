#version 330 compatibility

out vec2 vTexCoord;
out vec2 vLmCoord;
out vec4 vGlColor;

#include "common/common_vert.glsl"

void main() {
	gl_Position = ftransform();
	vTexCoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	vLmCoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vGlColor = gl_Color;

	VERT_COMMON();
}