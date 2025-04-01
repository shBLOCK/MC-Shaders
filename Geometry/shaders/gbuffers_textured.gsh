#include "common/common_geom.glsl"

in vec2 vTexCoord[];
out vec2 gTexCoord;
in vec2 vLmCoord[];
out vec2 gLmCoord;
in vec4 vGlColor[];
out vec4 gGlColor;

EMITTER_HEAD
gTexCoord = vTexCoord[i];
gLmCoord = vLmCoord[i];
gGlColor = vGlColor[i];
EMITTER_TAIL

MAIN()