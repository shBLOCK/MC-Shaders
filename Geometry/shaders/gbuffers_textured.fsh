#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform vec4 entityColor;

uniform float alphaTestRef = 0.1;

in vec2 gTexCoord;
in vec2 gLmCoord;
in vec4 gGlColor;

#include "common/common_frag.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	bool _discard = false;
	vec4 texcolor = texture(gtexture, gTexCoord);
	color = texcolor * gGlColor;
	color.rgb = mix(color.rgb, entityColor.rgb, entityColor.a);
	color *= texture(lightmap, gLmCoord);
	if (color.a < alphaTestRef) {
		_discard = true;
	}
	
	if (renderStage != MC_RENDER_STAGE_WORLD_BORDER && renderStage != MC_RENDER_STAGE_DESTROY) {
		fragCommon(_discard, color, texcolor);
	}
	if (_discard) discard;
}