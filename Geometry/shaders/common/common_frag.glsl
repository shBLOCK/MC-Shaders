#define INF intBitsToFloat(0x7F800000)

#define FRAME_THICKNESS 0.05 // [0.0 0.01 0.03 0.05 0.1 0.15 0.2 0.3 0.4 0.5]
#define FACE_FADE_OFFSET 5.0 // [-INF -50.0 -30.0 -20.0 -15.0 -10.0 -7.0 -5.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 5.0 7.0 10.0 15.0 20.0 30.0 50.0 INF] 
#define FACE_FADE_SPEED 0.1 // [0.01 0.05 0.1 0.2 0.3 0.5 1.0]
#define FRAME_FADE_OFFSET 30.0 // [-INF -200.0 -150.0 -100.0 -75.0 -50.0 -30.0 -20.0 -15.0 -10.0 -7.0 -5.0 -3.0 0.0 3.0 5.0 7.0 10.0 15.0 20.0 30.0 50.0 75.0 100.0 150.0 200.0 INF]
#define FRAME_FADE_SPEED 0.1 // [0.01 0.05 0.1 0.2 0.3 0.5 1.0]
#define FRAME_FADE_MIN 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]

in vec3 vMarker;
in float vDistance;

float max4(float a, float b, float c, float d) {
    return max(a, max(b, max(c, b)));
}

float minComponent(vec3 v) {
    return min(v.x, min(v.y, v.z));
}

#define FRAG_COMMON(edge, colored_edge, edge_color, fade) {\
    float a = minComponent(vMarker) * 2.0;\
    if (a >= ((vDistance - abs(FACE_FADE_OFFSET)) * FACE_FADE_SPEED * sign(FACE_FADE_OFFSET)) && fade) {\
\
    } else {\
        if (a > edge * FRAME_THICKNESS * clamp((abs(FRAME_FADE_OFFSET) - vDistance) * FRAME_FADE_SPEED * sign(FRAME_FADE_OFFSET), FRAME_FADE_MIN, 1.0)) {\
            _discard = true;\
        } else {\
            _discard = false;\
            color.a = 1.0;\
        }\
        if (a <= colored_edge) {\
            color = edge_color;\
            _discard = false;\
        }\
    }\
    if (_discard) discard;\
}