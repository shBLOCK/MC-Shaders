out vec4 vMarker;
out float vDistance;

#define VERT_COMMON() {\
    vMarker = vec4(0.0);\
	int id = gl_VertexID % 4;\
	if (id == 0) {\
		vMarker.x = 1.0;\
	} else if (id == 1) {\
		vMarker.y = 1.0;\
	} else if (id == 2) {\
		vMarker.z = 1.0;\
	} else {\
		vMarker.w = 1.0;\
	}\
\
    vDistance = length((gl_ModelViewMatrix * gl_Vertex).xyz);\
}