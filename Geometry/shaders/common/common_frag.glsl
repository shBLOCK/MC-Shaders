#include "settings.glsl"

#define INF intBitsToFloat(0x7F800000)

in vec3 gMarker;
in float gDistance;

float max4(float a, float b, float c, float d) {
    return max(a, max(b, max(c, b)));
}

float minComponent(vec3 v) {
    return min(v.x, min(v.y, v.z));
}

#if GEOMETRY_MODE == 0
    #define _FACE_SCALE 3.0
#elif GEOMETRY_MODE == 1
    #define _FACE_SCALE 2.0
#endif

#define FRAG_COMMON(edge, colored_edge, edge_color, fade) {\
    float a = minComponent(gMarker);\
    if ((a * _FACE_SCALE) >= ((gDistance - abs(FACE_FADE_OFFSET)) * FACE_FADE_SPEED * sign(FACE_FADE_OFFSET)) && fade) {\
\
    } else {\
        if (a > edge * FRAME_THICKNESS * clamp((abs(FRAME_FADE_OFFSET) - gDistance) * FRAME_FADE_SPEED * sign(FRAME_FADE_OFFSET), FRAME_FADE_MIN, 1.0)) {\
            _discard = true;\
        } else {\
            _discard = false;\
            color.a = 1.0;\
        }\
        if (a <= colored_edge) {\
            color = edge_color;\
            _discard = false;\
        }\
    }\
}