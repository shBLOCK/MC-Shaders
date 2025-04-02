#include "settings.glsl"

uniform int renderStage;

in vec3 gMarker;
in float gDistance;
flat in int gEntity;

in vec2 gFade;
flat in int gModeMask;
flat in int gIsFrontFace;

float max4(float a, float b, float c, float d) {
    return max(a, max(b, max(c, b)));
}

float minComponent(vec3 v) {
    return min(v.x, min(v.y, v.z));
}

bool _shouldIgnoreDiscard(vec4 texcolor) {
    if (texcolor.a == 0.0) {
        #ifdef KEEP_DISCARD_LISTED_BLOCKS_ZERO_ALPHA
            if (bool(gEntity & 128)) return false;
        #endif
    }

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

void fragCommon(inout bool _discard, inout vec4 color, in vec4 texcolor) {
    float a = minComponent(gMarker);

    #if GEOMETRY_MODE == 0
        #define _FACE_SCALE 3.0
    #elif GEOMETRY_MODE == 1
        #define _FACE_SCALE 2.0
    #endif

    if (a * _FACE_SCALE > (1.0 - gFade.x)) { // in fading face
        if (bool(gModeMask & 2)) {
            #if !(SHOW_BACKFACE & 2)
                if (!bool(gIsFrontFace)) _discard = true;
            #endif
        } else {
            _discard = true;
        }
    } else {
        if (bool(gModeMask & 1)) {
            if (a > FRAME_THICKNESS * clamp(gFade.y, FRAME_FADE_MIN, 1.0)) { // not in fading frame
                _discard = true;
            } else {
                if (_shouldIgnoreDiscard(texcolor)) {
                    _discard = false;
                    color.a = 1.0;
                }
                #if !(SHOW_BACKFACE & 1)
                    if (!bool(gIsFrontFace)) _discard = true;
                #endif
            }
            // if (a <= colored_edge) {
            //     color = edge_color;
            //     _discard = false;
            // }
        } else {
            #if FACE_FADE_MODE == 0
                _discard = true;
            #endif
        }
    }
}