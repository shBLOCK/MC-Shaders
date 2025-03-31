#version 330 compatibility

uniform sampler2D lightmap;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec4 glcolor;

#include "common_frag.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	bool _discard = false;
	color = glcolor * texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		_discard = true;
	}

	FRAG_COMMON(1.0, 0.0, vec4(0), true);
}