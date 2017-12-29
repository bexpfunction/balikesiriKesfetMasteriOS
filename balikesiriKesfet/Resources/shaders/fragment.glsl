#version 100
varying lowp vec4 color;
varying lowp vec3 normal;
varying mediump vec2 texcoord0;
uniform sampler2D Diffuse;
void main() {
    //gl_FragColor = texture2D(Diffuse,texcoord0);
    gl_FragColor = color;
    //gl_FragColor = vec4(texcoord0,0,1);
    //gl_FragColor = vec4(normal,1);
}
