#version 100
#extension GL_OES_standard_derivatives : enable
precision mediump float;
varying lowp vec4 color;
varying lowp vec3 normal;
varying mediump vec2 texcoord0;
uniform sampler2D Diffuse;

vec3 glyph_color    = vec3(1.0,1.0,1.0);
const float glyph_center   = 0.50;
void main() {
    vec2 st = texcoord0;
    vec4 color = texture2D(Diffuse,st);
    float dist  = color.r;
    float width = fwidth(dist);
    float alpha = smoothstep(glyph_center-width, glyph_center+width, dist);
    
    // Smooth
    gl_FragColor = vec4(glyph_color, alpha);
    //vec2 st = texcoord0;
    //st.y = 1.0-st.y;
    //st/=4.0;
    //gl_FragColor = texture2D(Diffuse,st);
    //gl_FragColor = vec4(1,0,0,1);
    //gl_FragColor = vec4(texcoord0,0,1);
    //gl_FragColor = vec4(normal,1);
}

