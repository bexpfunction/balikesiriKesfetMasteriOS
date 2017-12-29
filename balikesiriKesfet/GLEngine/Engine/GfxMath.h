//
// Created by alp19 on 24.08.2017.
//

#ifndef GLMINIENGINE_GFXMATH_H
#define GLMINIENGINE_GFXMATH_H


#include "types.h"

class GfxMath {

};

mat4 GFX_look_at( vec3 *eye, vec3 *center, vec3 *up );
vec3 ArbitraryRotate(vec3 p,double theta,vec3 r);

vec2 GFX_screenPos2DeviceCoords(int x,int y,vec2 size);
vec4 GFX_clipSpace2EyeCoords(vec4 clipCoords,mat4 *procetionMat);
vec3 GFX_eyeCoords2WordSpace(vec4 eyeCoords,mat4 *viewMat);

bool GFX_isPointInsideTriangle(vec3 *triangle,vec3 point);
float GFX_barycentricCoord(vec3 a,vec3 b,vec3 c,vec3 p);
#endif //GLMINIENGINE_GFXMATH_H
