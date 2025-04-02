#include "settings.glsl"

uniform mat4 modelViewMatrix;
uniform mat4 gbufferModelViewInverse;

uniform int renderStage;
uniform int blockEntityId;
in vec2 mc_Entity;

out vec3 vPos;
out vec3 vViewPos;
flat out vec3 vNormal;
out vec3 vMarker;
flat out int vEntity;

#if GEOMETRY_MODE == 0 // Triangle mode
	#define _VERT_MARKER() \
		vMarker = vec3[4](\
			vec3(1.0, 0.0, 0.0),\
			vec3(0.0, 1.0, 0.0),\
			vec3(0.0, 0.0, 1.0),\
			vec3(0.0, 1.0, 0.0)\
		)[gl_VertexID % 4];
#elif GEOMETRY_MODE == 1 // Quad mode
	#define _VERT_MARKER() \
		vMarker = vec3[4](\
			vec3(1.0, 1.0, 0.0),\
			vec3(0.0, 1.0, 0.0),\
			vec3(0.0, 1.0, 1.0),\
			vec3(0.0, 1.0, 0.0)\
		)[gl_VertexID % 4];
#endif

#define VERT_COMMON() {\
	vPos = gl_Vertex.xyz;\
	vViewPos = (gl_ModelViewMatrix * vec4(vPos, 1.0)).xyz;\
	gl_Position = gl_ProjectionMatrix * vec4(vViewPos, 1.0);\
	vNormal = gl_Normal;\
    vMarker = vec3(0.0);\
	_VERT_MARKER();\
	vEntity = max(0, int(mc_Entity.x));\
	if (renderStage == MC_RENDER_STAGE_BLOCK_ENTITIES) {\
		vEntity = max(0, blockEntityId);\
		if (vEntity == 65535) vEntity = 0;\
	}\
}