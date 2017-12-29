#version 100
//Uniforms
uniform mediump mat4 PROJECTIONMATRIX;
uniform mediump mat4 VIEWMAT;
uniform mediump mat4 MODELMAT;
uniform mediump vec3 CAM_POS;    //CameraPosition
uniform mediump float OFFSET;
uniform lowp vec4 COLOR1;
uniform lowp vec4 COLOR2;
//Attributes
attribute mediump vec4 POSITION;
attribute mediump vec3 NORMALS;
//attribute mediump vec2 TEXCOORD0;
//Varyings(OUTS for fragment)
//varying mediump vec2 texcoord0;
varying lowp vec4 color;
//varying lowp vec3 normal;

//vec4 cam_up;
vec3 cam_right;
vec4 worldSpace;
void main(void){
    vec3 camDir = normalize(MODELMAT[3].xyz - CAM_POS);
    cam_right = cross(vec3(0,1,0),camDir);
    worldSpace = vec4(cam_right,1) * POSITION.x;
    worldSpace.y = POSITION.y;
    worldSpace.w = POSITION.w;
    worldSpace += vec4(camDir,0)*OFFSET;

    mat4 mvp = PROJECTIONMATRIX * VIEWMAT * MODELMAT;
    gl_Position = mvp * worldSpace;

    //color = vec4(NORMALS,1);
    color = mix(COLOR2,COLOR1,NORMALS.z);
    //normal = NORMALS;
    //texcoord0 = TEXCOORD0;
}
