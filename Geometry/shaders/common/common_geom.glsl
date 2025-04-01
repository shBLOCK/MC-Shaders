#version 330 compatibility

#include "settings.glsl"

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

in vec3 vMarker[];
out vec3 gMarker;
in float vDistance[];
out float gDistance;

#if DISTANCE_MODE == 0 // per-vertex mode
    #define _IO_DISTANCE gDistance = vDistance[i];
#elif DISTANCE_MODE == 1 // per-primitive mode
    #define _IO_DISTANCE ; // don't do anything, vDistance is already set in main()
#endif

#define EMITTER_HEAD void emit(int i) {\
    gl_Position = gl_in[i].gl_Position;\
    gMarker = vMarker[i];\
    _IO_DISTANCE;
#define EMITTER_TAIL \
    EmitVertex();\
}

#if DISTANCE_MODE == 0
    #define _MAIN_DISTANCE ;
#elif DISTANCE_MODE == 1
    #if GEOMETRY_MODE == 0
        #define _MAIN_DISTANCE gDistance = (vDistance[0] + vDistance[1] + vDistance[2]) / 3.0;
    #elif GEOMETRY_MODE == 1
        #define _MAIN_DISTANCE gDistance = (vDistance[0] + vDistance[2]) / 2.0;
    #endif
#endif

#define MAIN() void main() {\
    _MAIN_DISTANCE;\
    emit(0);\
    emit(1);\
    emit(2);\
    EndPrimitive();\
}