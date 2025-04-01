#version 330 compatibility

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

//region Distance
#if DISTANCE_MODE == 0 // per-vertex
    #define _IO_DISTANCE gDistance = length(vViewPos[i]);
#elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2
    #define _IO_DISTANCE ; // don't do anything, gDistance is already set in main()
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
//endregion

#define SETUP_VERTEX_HEAD void setupVertex(int i) {\
    gl_Position = gl_in[i].gl_Position;\
    gMarker = vMarker[i];\
    _IO_DISTANCE;\
    gFade.x = (abs(FACE_FADE_OFFSET) - gDistance) * FACE_FADE_SPEED * sign(FACE_FADE_OFFSET) + 1.0;\
    gFade.y = (abs(FRAME_FADE_OFFSET) - gDistance) * FRAME_FADE_SPEED * sign(FRAME_FADE_OFFSET) + 1.0;\
    gEntity = vEntity[i];
#define SETUP_VERTEX_TAIL \
}

#ifdef FACE_SEPARATE
    float _sideLengthSum(vec3 a, vec3 b, vec3 c) {
        return distance(a, b) + distance(b, c) + distance(a, c);
    }

    void _setupFaceVertex(int i) {
        vec3 pos = vPos[i];
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

bool shouldDiscard() {
    //TODO
    return false;
}

#define MAIN() void main() {\
    gModeMask = _MAIN_EX_MODE_MASK;\
    _MAIN_EX_DISTANCE;\
    if (shouldDiscard()) return;\
    setupVertex(0);\
    EmitVertex();\
    setupVertex(1);\
    EmitVertex();\
    setupVertex(2);\
    EmitVertex();\
    EndPrimitive();\
    _MAIN_EX_FACE;\
}