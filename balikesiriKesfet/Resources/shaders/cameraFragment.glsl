//#extension GL_OES_EGL_image_external : enable
precision mediump float;
varying mediump vec2 texcoord0;
//in mediump vec2 texcoord0;
//uniform samplerExternalOES Diffuse;
uniform sampler2D DiffuseY;
uniform sampler2D DiffuseUV;

//out highp vec4 fragmentColor;
void main() {
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    yuv.x = texture2D(DiffuseY, texcoord0).r;
    yuv.yz = texture2D(DiffuseUV, texcoord0).rg - vec2(0.5, 0.5);
    
    // BT.601, which is the standard for SDTV is provided as a reference
    
    rgb = mat3(    1,       1,     1,
               0, -.34413, 1.772,
               1.402, -.71414,     0) * yuv;
    
    
    // Using BT.709 which is the standard for HDTV
    /*rgb = mat3(      1,       1,      1,
     0, -.18732, 1.8556,
     1.57481, -.46813,      0) * yuv;*/
    
    gl_FragColor = vec4(rgb, 1);
    //gl_FragColor = texture2D(Diffuse,texcoord0);
    //fragmentColor = texture(Diffuse,texcoord0);
}
