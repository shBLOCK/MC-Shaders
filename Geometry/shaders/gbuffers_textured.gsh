#include "common/common_geom.glsl"

in vec2 vTexCoord[];
out vec2 gTexCoord;
in vec2 vLmCoord[];
out vec2 gLmCoord;
in vec4 vGlColor[];
out vec4 gGlColor;

SETUP_VERTEX_HEAD
gTexCoord = vTexCoord[i];
gLmCoord = vLmCoord[i];
gGlColor = vGlColor[i];
SETUP_VERTEX_TAIL

MAIN()