#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform vec4 entityColor;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

#include "common/common_frag.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	bool _discard = false;
	color = texture(gtexture, texcoord) * glcolor;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		_discard = true;
	}
	
	FRAG_COMMON(1.0, -1.0, vec4(0), true);
}