#version 330 compatibility

#include "utils.glsl"
#include "settings.glsl"

layout(triangles) in;
#ifndef FACE_SEPARATE
    layout(triangle_strip, max_vertices = 3) out;
#else
    layout(triangle_strip, max_vertices = 6) out;
#endif

in vec3 vPos[];
in vec3 vViewPos[];
in vec3 vNormal[];

in vec3 vMarker[];
out vec3 gMarker;
flat in int vEntity[];
flat out int gEntity;

out float gDistance;
out vec2 gFade;
flat out int gModeMask;

void _updateFade() {
    gFade.x = (abs(FACE_FADE_OFFSET) - gDistance) * FACE_FADE_SPEED * sign(FACE_FADE_OFFSET) + 1.0;
    gFade.y = (abs(FRAME_FADE_OFFSET) - gDistance) * FRAME_FADE_SPEED * sign(FRAME_FADE_OFFSET) + 1.0;
    gFade = clamp(gFade, vec2(-1e30), vec2(1e30));
}

#if DISTANCE_MODE == 0 // per-vertex
    #define _SETUP_DISTANCE gDistance = length(vViewPos[i]);
    #define _SETUP_FADE _updateFade();
#elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2
    #define _SETUP_DISTANCE ; // don't do anything, gDistance is already set in main()
    #define _SETUP_FADE ;
#endif

#if DISTANCE_MODE == 0
    #define _MAIN_EX_DISTANCE ;
#elif DISTANCE_MODE == 1
    #if GEOMETRY_MODE == 0
        #define _MAIN_EX_DISTANCE gDistance = length((vViewPos[0] + vViewPos[1] + vViewPos[2]) / 3.0);
    #elif GEOMETRY_MODE == 1
        #define _MAIN_EX_DISTANCE gDistance = length((vViewPos[0] + vViewPos[2]) / 2.0);
    #endif
#elif DISTANCE_MODE == 2
    #if GEOMETRY_MODE == 0
        #define _MAIN_EX_DISTANCE gDistance = min(length(vViewPos[0]), min(length(vViewPos[1]), length(vViewPos[2])));
    #elif GEOMETRY_MODE == 1
        #define _MAIN_EX_DISTANCE gDistance = min(length(vViewPos[0]), length(vViewPos[2]));
    #endif
#endif

#if DISTANCE_MODE == 0
    #define _MAIN_EX_FADE ;
#elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2
    #define _MAIN_EX_FADE _updateFade();
#endif

#define SETUP_VERTEX_HEAD void setupVertex(int i) {\
    gl_Position = gl_in[i].gl_Position;\
    gMarker = vMarker[i];\
    _SETUP_DISTANCE;\
    _SETUP_FADE;\
    gEntity = vEntity[i];
#define SETUP_VERTEX_TAIL \
}

#ifdef FACE_SEPARATE
    float _sideLengthSum(vec3 a, vec3 b, vec3 c) {
        return distance(a, b) + distance(b, c) + distance(a, c);
    }

    void _setupFaceVertex(int i) {
        vec3 pos = vPos[i];

        #if FACE_FADE_MODE == 1 // scale mode
            #if GEOMETRY_MODE == 0
                vec3 center = (vPos[0] + vPos[1] + vPos[2]) / 3.0;
            #elif GEOMETRY_MODE == 1
                vec3 center = (vPos[0] + vPos[2]) / 2.0;
            #endif
            pos = mix(pos, center, clamp(1.0 - gFade.x, 0.0, 1.0));
        #endif

        vec3 normal = vNormal[i];
        if (FACE_NORMAL_DISPLACEMENT != 0.0) {
            bool isOrthogonal = abs(max(abs(normal.x), max(abs(normal.y), abs(normal.z))) - 1.0) < 0.01;
            if ((gEntity & 256) != 0) {
            } else if ((gEntity & 512) != 0 && !isOrthogonal) {
            } else {
                vec3 dir = normal;
                float size = _sideLengthSum(vViewPos[0], vViewPos[1], vViewPos[2]);
                if ((gEntity & 1024) != 0) dir = vec3(0.0, 1.0, 0.0);
                if ((gEntity & 2048) != 0 && !isOrthogonal) dir = vec3(0.0, 1.0, 0.0);
                pos += dir * (size * pow(clamp(1.0 - gFade.x, 0.0, 1.0), FACE_NORMAL_DISPLACEMENT_CURVE) * FACE_NORMAL_DISPLACEMENT);
            }
        }
        gl_Position = gl_ModelViewMatrix * vec4(pos, 1.0);
        gl_Position = gl_ProjectionMatrix * vec4(gl_Position.xyz, 1.0);
    }

    #define _MAIN_EX_FACE {\
        gModeMask = 2; /* 0b10 */\
        setupVertex(0);\
        _setupFaceVertex(0);\
        EmitVertex();\
        setupVertex(1);\
        _setupFaceVertex(1);\
        EmitVertex();\
        setupVertex(2);\
        _setupFaceVertex(2);\
        EmitVertex();\
        EndPrimitive();\
    }
#else
    #define _MAIN_EX_FACE ;
#endif

#ifndef FACE_SEPARATE
    #define _MAIN_EX_MODE_MASK 3 // 0b11
#else
    #define _MAIN_EX_MODE_MASK 1 // 0b01
#endif

bool _shouldDiscard() {
    #if DISTANCE_MODE == 0
        for (int i = 0; i < 3; i++) {
            gDistance = length(vViewPos[i]);
            _updateFade();
            if (gFade.x > 0.0 || gFade.y > 0.0) return false;
        }
        return true;
    #elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2
        // gFade should have been set up already
        if (gFade.x < 0.0 && gFade.y < 0.0) return true;
    #endif
    
    return false;
}

#define MAIN() void main() {\
    gModeMask = _MAIN_EX_MODE_MASK;\
    _MAIN_EX_DISTANCE;\
    _MAIN_EX_FADE;\
    if (_shouldDiscard()) return;\
    setupVertex(0);\
    EmitVertex();\
    setupVertex(1);\
    EmitVertex();\
    setupVertex(2);\
    EmitVertex();\
    EndPrimitive();\
    _MAIN_EX_FACE;\
}