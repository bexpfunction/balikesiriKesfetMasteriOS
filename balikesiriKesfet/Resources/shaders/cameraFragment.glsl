#version 100
//#extension GL_OES_EGL_image_external : enable
precision mediump float;
varying mediump vec2 texcoord0;
//in mediump vec2 texcoord0;
//uniform samplerExternalOES Diffuse;
uniform sampler2D Diffuse;      //made changes

//out highp vec4 fragmentColor;
void main() {
    gl_FragColor = texture2D(Diffuse,texcoord0);
    //fragmentColor = texture(Diffuse,texcoord0);
}
