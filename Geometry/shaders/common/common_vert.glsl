#define GEOMETRY_MODE 0 // [0 1]

out vec3 vMarker;
out float vDistance;

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
    vMarker = vec3(0.0);\
	_VERT_MARKER();\
	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;\
    vDistance = length(viewPos);\
}