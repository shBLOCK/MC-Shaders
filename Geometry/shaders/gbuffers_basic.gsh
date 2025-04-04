#include "common/common_geom_head.glsl"

in vec2 vLmCoord[];
out vec2 gLmCoord;
in vec4 vGlColor[];
out vec4 gGlColor;

#define SETUP_VERTEX_EXTRA(i) \
    gLmCoord = vLmCoord[i];\
    gGlColor = vGlColor[i];

#include "common/common_geom_tail.glsl"