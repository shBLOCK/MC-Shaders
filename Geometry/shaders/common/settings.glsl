#include "utils.glsl"

#define FRAME_THICKNESS 0.03 // [0.0 0.01 0.03 0.05 0.1 0.15 0.2 0.3 0.4 0.5]

// 0: triangle; 1: quad
#define GEOMETRY_MODE 0 // [0 1]
// 0: per vertex; 1: primitive center; 2: min vertex
#define DISTANCE_MODE 1 // [0 1 2]

#define FACE_FADE_OFFSET 5.0 // [-INF -50.0 -30.0 -20.0 -15.0 -10.0 -7.0 -5.0 -3.0 -2.0 -1.0 0.0 1.0 2.0 3.0 5.0 7.0 10.0 15.0 20.0 30.0 50.0 INF] 
#define FACE_FADE_SPEED 0.15 // [0.01 0.05 0.1 0.15 0.2 0.3 0.5 1.0]
#define FRAME_FADE_OFFSET 30.0 // [-INF -200.0 -150.0 -100.0 -75.0 -50.0 -30.0 -20.0 -15.0 -10.0 -7.0 -5.0 -3.0 0.0 3.0 5.0 7.0 10.0 15.0 20.0 30.0 50.0 75.0 100.0 150.0 200.0 INF]
#define FRAME_FADE_SPEED 0.1 // [0.01 0.05 0.1 0.15 0.2 0.3 0.5 1.0]
#define FRAME_FADE_MIN 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9]

#define KEEP_DISCARD_ENTITIES_ZERO_ALPHA
#define KEEP_DISCARD_ENTITIES_BLACK
#define KEEP_DISCARD_ENTITIES_WHITE
#define KEEP_DISCARD_HAND_ZERO_ALPHA
#define KEEP_DISCARD_HAND_BLACK
#define KEEP_DISCARD_HAND_WHITE
#define KEEP_DISCARD_LISTED_BLOCKS_ZERO_ALPHA

// 0: clip; 1: scale
#define FACE_FADE_MODE 0 // [0 1]
// #define FACE_SEPARATE
#define FACE_NORMAL_DISPLACEMENT 0.0 // [0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define FACE_NORMAL_DISPLACEMENT_CURVE 3.0 // [0.25 0.5 1.0 2.0 3.0 4.0 5.0]