//Uniforms
//uniform mediump mat4 PROJECTIONMATRIX;
//uniform mediump mat4 VIEWMAT;
//uniform mediump mat4 MODELMAT;
//Attributes
attribute mediump vec4 POSITION;
//in vec4 POSITION;
attribute mediump vec2 TEXCOORD0;
//in vec2 TEXCOORD0;

//Varyings(outputs for fragment shader)
//out vec2 texcoord0;
varying mediump vec2 texcoord0;
void main(void){
    //mat4 mvp = PROJECTIONMATRIX * VIEWMAT * MODELMAT;
    texcoord0 = TEXCOORD0;
    gl_Position = POSITION;}
