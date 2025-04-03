vec2 _clampInf(vec2 vec) {
    return clamp(vec, -1e30, 1e30);
}

vec2 _getFade(float d) {
    return vec2(
        (abs(FACE_FADE_OFFSET) - d) * (1.0 / FACE_FADE_REGION) * sign(FACE_FADE_OFFSET) + 1.0, // x: face
        (abs(FRAME_FADE_OFFSET) - d) * (1.0 / FRAME_FADE_REGION) * sign(FRAME_FADE_OFFSET) + 1.0 // y: frame
    );
}

#define SETUP_VERTEX(i) \
    gl_Position = gl_in[i].gl_Position;\
    gMarker = vMarker[i];\
    gDistance = M_DISTANCE(i);\
    gFade = _clampInf(M_FADE(i));\
    gEntity = m_entity;\
    SETUP_VERTEX_EXTRA(i)

float _calcSideLengthSum(vec3 a, vec3 b, vec3 c) {
    return distance(a, b) + distance(b, c) + distance(a, c);
}

void main() {
    int m_entity = vEntity[0];

    // gModeMask
    #ifndef FACE_SEPARATE
        gModeMask = 3; // 0b11
    #else
        gModeMask = 1; // 0b01
    #endif

    // calculate primitive center
    #if GEOMETRY_MODE == 0
        vec3 m_center = (vPos[0] + vPos[1] + vPos[2]) / 3.0;
    #elif GEOMETRY_MODE == 1
        vec3 m_center = (vPos[0] + vPos[2]) / 2.0;
    #endif

    // calculate distance
    #if DISTANCE_MODE == 0
        float m_distance[3] = float[3](
            length(vViewPos[0]),
            length(vViewPos[1]),
            length(vViewPos[2])
        );
    #elif DISTANCE_MODE == 1
        #if GEOMETRY_MODE == 0
            float m_distance = length((vViewPos[0] + vViewPos[1] + vViewPos[2]) / 3.0);
        #elif GEOMETRY_MODE == 1
            float m_distance = length((vViewPos[0] + vViewPos[2]) / 2.0);
        #endif
    #elif DISTANCE_MODE == 2
        #if GEOMETRY_MODE == 0
            float m_distance = min(length(vViewPos[0]), min(length(vViewPos[1]), length(vViewPos[2])));
        #elif GEOMETRY_MODE == 1
            float m_distance = min(length(vViewPos[0]), length(vViewPos[2]));
        #endif
    #endif
    
    // calculate fade
    #if DISTANCE_MODE == 0
        vec2 m_fade[3] = vec2[3](
            _getFade(m_distance[0]),
            _getFade(m_distance[1]),
            _getFade(m_distance[2])
        );
        bool _frameNotFaded = m_fade[0].y >= 0.0 || m_fade[1].y >= 0.0 || m_fade[2].y >= 0.0;
    #elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2
        vec2 m_fade = _getFade(m_distance);
        bool _frameNotFaded = m_fade.y >= 0.0;
    #endif

    // convinent macros
    #if DISTANCE_MODE == 0
        #define M_DISTANCE(i) m_distance[i]
        #define M_FADE(i) m_fade[i]
    #elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2
        #define M_DISTANCE(i) m_distance
        #define M_FADE(i) m_fade
    #endif

    bool noInvertBackface = false;
    #ifdef IN_VERTEX_TEXCOORD
        // don't invert backface for inner surfaces of double surface blocks (e.g. water, lava, powder_snow)
        if (determinant(mat2(IN_VERTEX_TEXCOORD[0] - IN_VERTEX_TEXCOORD[1], IN_VERTEX_TEXCOORD[2] - IN_VERTEX_TEXCOORD[1])) < 0.0)
            noInvertBackface = true;
    #endif

    if (_frameNotFaded) {
        bool isFrontface = dot(vViewPos[0], gl_NormalMatrix * vNormal[0]) <= 0.0;

        if ( // backface guard
            #ifdef FACE_SEPARATE
                #if !(SHOW_BACKFACE & 1) // if don't show backface for frame
                    isFrontface
                #else
                    true
                #endif
            #else
                #if !((SHOW_BACKFACE & 1) || (SHOW_BACKFACE & 2)) // if don't show backface for both frame & face
                    isFrontface
                #else
                    true
                #endif
            #endif
        ) {
            gIsFrontFace = int(isFrontface);

            {SETUP_VERTEX(0)}
            EmitVertex();
            if (isFrontface || noInvertBackface) {
                {SETUP_VERTEX(1)}
                EmitVertex();
                {SETUP_VERTEX(2)}
                EmitVertex();
            } else {
                {SETUP_VERTEX(2)}
                EmitVertex();
                {SETUP_VERTEX(1)}
                EmitVertex();
            }
            EndPrimitive();
        }
    }

    #ifdef FACE_SEPARATE
        #if DISTANCE_MODE == 0
            bool _faceNotFaded = m_fade[0].x >= 0.0 || m_fade[1].x >= 0.0 || m_fade[2].x >= 0.0;
        #elif DISTANCE_MODE == 1 || DISTANCE_MODE == 2
            bool _faceNotFaded = m_fade.x >= 0.0;
        #endif

        if (_faceNotFaded) {
            gModeMask = 2; // 0b10

            vec3 pos[3] = vec3[3](vPos[0], vPos[1], vPos[2]);
            vec3 normal = vNormal[0];

            #if FACE_FADE_MODE == 1
                pos[0] = mix(pos[0], m_center, clamp(1.0 - M_FADE(0).x, 0.0, 1.0));
                pos[1] = mix(pos[1], m_center, clamp(1.0 - M_FADE(1).x, 0.0, 1.0));
                pos[2] = mix(pos[2], m_center, clamp(1.0 - M_FADE(2).x, 0.0, 1.0));
            #endif
            
            if (FACE_DISPLACEMENT != 0.0) {
                bool isOrthogonal = abs(max(abs(normal.x), max(abs(normal.y), abs(normal.z))) - 1.0) < 0.01;
                if (bool(m_entity & 256)) {
                } else if (bool(m_entity & 512) && !isOrthogonal) {
                } else {
                    vec3 baseDisplacement = normal;
                    if (bool(m_entity & 1024)) baseDisplacement = vec3(0.0, 1.0, 0.0);
                    if (bool(m_entity & 2048) && !isOrthogonal) baseDisplacement = vec3(0.0, 1.0, 0.0);
                    baseDisplacement *= _calcSideLengthSum(vViewPos[0], vViewPos[1], vViewPos[2]);

                    pos[0] += baseDisplacement * pow(clamp(1.0 - M_FADE(0).x, 0.0, 1.0), FACE_DISPLACEMENT_CURVE) * FACE_DISPLACEMENT;
                    pos[1] += baseDisplacement * pow(clamp(1.0 - M_FADE(1).x, 0.0, 1.0), FACE_DISPLACEMENT_CURVE) * FACE_DISPLACEMENT;
                    pos[2] += baseDisplacement * pow(clamp(1.0 - M_FADE(2).x, 0.0, 1.0), FACE_DISPLACEMENT_CURVE) * FACE_DISPLACEMENT;
                }
            }

            pos[0] = (gl_ModelViewMatrix * vec4(pos[0], 1.0)).xyz;
            pos[1] = (gl_ModelViewMatrix * vec4(pos[1], 1.0)).xyz;
            pos[2] = (gl_ModelViewMatrix * vec4(pos[2], 1.0)).xyz;

            bool isFrontface = dot(pos[0], cross(pos[2] - pos[1], pos[0] - pos[1])) <= 0.0;

            if ( // backface guard
                #if !(SHOW_BACKFACE & 2)
                    isFrontface
                #else
                    true
                #endif
            ) {
                gIsFrontFace = int(isFrontface);

                #define SETUP_VERTEX_FACE(i) \
                    SETUP_VERTEX(i)\
                    gl_Position = gl_ProjectionMatrix * vec4(pos[i], 1.0);

                {SETUP_VERTEX_FACE(0)}
                EmitVertex();
                if (isFrontface || noInvertBackface) {
                    {SETUP_VERTEX_FACE(1)}
                    EmitVertex();
                    {SETUP_VERTEX_FACE(2)}
                    EmitVertex();
                } else {
                    {SETUP_VERTEX_FACE(2)}
                    EmitVertex();
                    {SETUP_VERTEX_FACE(1)}
                    EmitVertex();
                }
                EndPrimitive();
            }
        }
    #endif
}