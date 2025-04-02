#version 330 compatibility

#include "utils.glsl"
#include "settings.glsl"

layout(triangles) in;
#ifndef FACE_SEPARATE
    layout(triangle_strip, max_vertices = 3) out;
#else
    layout(triangle_strip, max_vertices = 6) out;
#endif

in vec3 vPos[3];
in vec3 vViewPos[3];
flat in vec3 vNormal[3];

in vec3 vMarker[3];
out vec3 gMarker;
flat in int vEntity[3];
flat out int gEntity;

out float gDistance;
out vec2 gFade;
flat out int gModeMask;
flat out int gIsFrontFace;