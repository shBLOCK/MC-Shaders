#version 330 compatibility

uniform sampler2D lightmap;

uniform float alphaTestRef = 0.1;

in vec2 gLmCoord;
in vec4 gGlColor;

#include "common/common_frag.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	bool _discard = false;
	vec4 texcolor = vec4(-1.0);
	color = gGlColor * texture(lightmap, gLmCoord);
	if (color.a < alphaTestRef) {
		_discard = true;
	}

	if (renderStage != MC_RENDER_STAGE_OUTLINE && renderStage != MC_RENDER_STAGE_DEBUG) {
		FRAG_COMMON(1.0, -1.0, vec4(0), true);
	}

	if (_discard) discard;
}