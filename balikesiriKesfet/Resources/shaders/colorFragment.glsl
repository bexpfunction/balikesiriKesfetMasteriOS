#version 100
varying lowp vec4 color;
void main() {
    gl_FragColor = vec4(color.xyz,0.5);
}
