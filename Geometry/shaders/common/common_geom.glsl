#version 330 compatibility

#include "settings.glsl"

layout(triangles) in;
#ifndef FACE_SEPARATE
    layout(triangle_strip, max_vertices = 3) out;
#else
    layout(triangle_strip, max_vertices = 6) out;
#endif

in vec3 vViewPos[];
in vec3 vNormal[];

in vec3 vMarker[];
out vec3 gMarker;
in float vDistance[];
out float gDistance;
flat in int vEntity[];
flat out int gEntity;

flat out int gModeMask;

#if DISTANCE_MODE == 0 // per-vertex mode
    #define _IO_DISTANCE gDistance = vDistance[i];
#elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2 // per-primitive mode
    #define _IO_DISTANCE ; // don't do anything, vDistance is already set in main()
#endif

#define SETUP_VERTEX_HEAD void setupVertex(int i) {\
    gl_Position = gl_in[i].gl_Position;\
    gMarker = vMarker[i];\
    _IO_DISTANCE;\
    gEntity = vEntity[i];
#define SETUP_VERTEX_TAIL \
}

#if DISTANCE_MODE == 0
    #define _MAIN_EX_DISTANCE ;
#elif DISTANCE_MODE == 1
    #if GEOMETRY_MODE == 0
        #define _MAIN_EX_DISTANCE gDistance = (vDistance[0] + vDistance[1] + vDistance[2]) / 3.0;
    #elif GEOMETRY_MODE == 1
        #define _MAIN_EX_DISTANCE gDistance = (vDistance[0] + vDistance[2]) / 2.0;
    #endif
#elif DISTANCE_MODE == 2
    #if GEOMETRY_MODE == 0
        #define _MAIN_EX_DISTANCE gDistance = min(vDistance[0], min(vDistance[1], vDistance[2]));
    #elif GEOMETRY_MODE == 1
        #define _MAIN_EX_DISTANCE gDistance = min(vDistance[0], vDistance[2]);
    #endif
#endif

#ifdef FACE_SEPARATE
    void setupFaceVertex(int i) {
        vec3 pos = vViewPos[i];
        vec3 normal = vNormal[i];
        pos += normal * 0.2;
        gl_Position = gl_ProjectionMatrix * vec4(pos, 1.0);
    }

    #define _MAIN_EX_FACE {\
        gModeMask = 2; /* 0b10 */\
        setupVertex(0);\
        setupFaceVertex(0);\
        EmitVertex();\
        setupVertex(1);\
        setupFaceVertex(1);\
        EmitVertex();\
        setupVertex(2);\
        setupFaceVertex(2);\
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

#define MAIN() void main() {\
    gModeMask = _MAIN_EX_MODE_MASK;\
    _MAIN_EX_DISTANCE;\
    setupVertex(0);\
    EmitVertex();\
    setupVertex(1);\
    EmitVertex();\
    setupVertex(2);\
    EmitVertex();\
    EndPrimitive();\
    _MAIN_EX_FACE;\
}