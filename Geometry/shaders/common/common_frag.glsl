#include "settings.glsl"

#define INF intBitsToFloat(0x7F800000)

uniform int renderStage;

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

bool _shouldIgnoreDiscard(vec4 texcolor) {
    switch (renderStage) {
        case MC_RENDER_STAGE_ENTITIES:
            #ifdef KEEP_DISCARD_ENTITIES_ZERO_ALPHA
                if (texcolor.a == 0.0) return false;
            #endif
            #ifdef KEEP_DISCARD_ENTITIES_BLACK
                if (texcolor.rgb == vec3(0.0)) return false;
            #endif
            #ifdef KEEP_DISCARD_ENTITIES_WHITE
                if (texcolor.rgb == vec3(1.0)) return false;
            #endif
            break;
        case MC_RENDER_STAGE_HAND_SOLID:
        case MC_RENDER_STAGE_HAND_TRANSLUCENT:
            #ifdef KEEP_DISCARD_HAND_ZERO_ALPHA
                if (texcolor.a == 0.0) return false;
            #endif
            #ifdef KEEP_DISCARD_HAND_BLACK
                if (texcolor.rgb == vec3(0.0)) return false;
            #endif
            #ifdef KEEP_DISCARD_HAND_WHITE
                if (texcolor.rgb == vec3(1.0)) return false;
            #endif
            break;
    }
    return true;
}

#define FRAG_COMMON(edge, colored_edge, edge_color, fade) {\
    float a = minComponent(gMarker);\
    if ((a * _FACE_SCALE) >= ((gDistance - abs(FACE_FADE_OFFSET)) * FACE_FADE_SPEED * sign(FACE_FADE_OFFSET)) && fade) {\
\
    } else {\
        if (a > edge * FRAME_THICKNESS * clamp((abs(FRAME_FADE_OFFSET) - gDistance) * FRAME_FADE_SPEED * sign(FRAME_FADE_OFFSET), FRAME_FADE_MIN, 1.0)) {\
            _discard = true;\
        } else {\
            if (_shouldIgnoreDiscard(texcolor)) {\
                _discard = false;\
                color.a = 1.0;\
            }\
        }\
        if (a <= colored_edge) {\
            color = edge_color;\
            _discard = false;\
        }\
    }\
}