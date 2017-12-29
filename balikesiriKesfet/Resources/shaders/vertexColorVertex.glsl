#version 100
//uniform mediump mat4 MODELVIEWPROJECTIONMATRIX;
uniform mediump mat4 PROJECTIONMATRIX;
uniform mediump mat4 VIEWMAT;
uniform mediump mat4 MODELMAT;
uniform lowp vec4 COLOR;

attribute mediump vec4 POSITION;
attribute mediump vec3 NORMALS;
//attribute lowp vec4 COLOR;
attribute mediump vec2 TEXCOORD0;

varying mediump vec2 texcoord0;
varying lowp vec4 color;
varying lowp vec3 normal;
void main(void){
    mat4 mvp = PROJECTIONMATRIX * VIEWMAT * MODELMAT;

    //gl_Position = MODELMAT * POSITION;
    //gl_Position = MODELMAT * PROJECTIONMATRIX * POSITION;
    //color = COLOR;
    color = COLOR;
    normal = NORMALS;
    texcoord0 = TEXCOORD0;
    gl_Position = mvp * POSITION;



	}
