#include "settings.glsl"

uniform mat4 modelViewMatrix;
uniform mat4 gbufferModelViewInverse;

in vec2 mc_Entity;

out vec3 vPos;
out vec3 vViewPos;
out vec3 vNormal;
out vec3 vMarker;
flat out int vEntity;

#if GEOMETRY_MODE == 0 // Triangle mode
	#define _VERT_MARKER() \
		int id = gl_VertexID % 4;\
		if (id == 0) {\
			vMarker.x = 1.0;\
		} else if (id == 1) {\
			vMarker.y = 1.0;\
		} else if (id == 2) {\
			vMarker.z = 1.0;\
		} else {\
			vMarker.y = 1.0;\
		}
#elif GEOMETRY_MODE == 1 // Quad mode
	#define _VERT_MARKER() \
		int id = gl_VertexID % 4;\
		if (id == 0) {\
			vMarker.x = 1.0;\
			vMarker.y = 1.0;\
		} else if (id == 1) {\
			vMarker.y = 1.0;\
		} else if (id == 2) {\
			vMarker.z = 1.0;\
			vMarker.y = 1.0;\
		} else {\
			vMarker.y = 1.0;\
		}
#endif

#define VERT_COMMON() {\
	vPos = gl_Vertex.xyz;\
	vViewPos = (gl_ModelViewMatrix * vec4(vPos, 1.0)).xyz;\
	gl_Position = gl_ProjectionMatrix * vec4(vViewPos, 1.0);\
	vNormal = gl_Normal;\
    vMarker = vec3(0.0);\
	_VERT_MARKER();\
	vEntity = int(mc_Entity.x);\
}