
#include <math.h>
#include "GfxMath.h"
#include "matrix.h"
#include "vector.h"
#include "types.h"
#include "../Logger.h"

mat4 GFX_look_at( vec3 *position, vec3 *target, vec3 *up )
{
    vec3 zaxis,xaxis,yaxis;
    // 1. Position = known
    // 2. Calculate cameraDirection
    vec3_diff(&zaxis,target,position );     //vec3_log((char *)"Diff",&zaxis);
    vec3_normalize(&zaxis,&zaxis);          //vec3_log((char *)"Diff norm",&zaxis);
    //glm::vec3 zaxis = glm::normalize(position - target);
    // 3. Get positive right axis vector
    vec3_cross(&xaxis,up,&zaxis);           //vec3_log((char *)"Cross Up to x",&xaxis);
    vec3_normalize(&xaxis,&xaxis);          //vec3_log((char *)"xaxis",&xaxis);
    //glm::vec3 xaxis = glm::normalize(glm::cross(glm::normalize(worldUp), zaxis));
    // 4. Calculate camera up vector
    vec3_cross(&yaxis,&zaxis,&xaxis);       //vec3_log((char *)"Cross f&x to y",&yaxis);
    //glm::vec3 yaxis = glm::cross(zaxis, xaxis);

    // Create translation and rotation matrix
    // In glm we access elements as mat[col][row] due to column-major layout

    mat4 translation; // Identity matrix by default
    mat4_identity(&translation);
    translation.m[3].x = -position->x;
    translation.m[3].y = -position->y;
    translation.m[3].z = -position->z;
    mat4 rotation;
    mat4_identity(&rotation);
    rotation.m[0].x = xaxis.x; // First column, first row
    rotation.m[1].x = xaxis.y;
    rotation.m[2].x = xaxis.z;
    rotation.m[0].y = yaxis.x; // First column, second row
    rotation.m[1].y = yaxis.y;
    rotation.m[2].y = yaxis.z;
    rotation.m[0].z = -zaxis.x; // First column, third row
    rotation.m[1].z = -zaxis.y;
    rotation.m[2].z = -zaxis.z;

    /*rotation.m[3].x = -position->x;
    rotation.m[3].y = -position->y;
    rotation.m[3].z = -position->z;*/

    /*rotation.m[0].x = xaxis.x; // First column, first row
    rotation.m[0].y = xaxis.y;
    rotation.m[0].z = xaxis.z;
    rotation.m[1].x = yaxis.x; // First column, second row
    rotation.m[1].y = yaxis.y;
    rotation.m[1].z = yaxis.z;
    rotation.m[2].x = -zaxis.x; // First column, third row
    rotation.m[2].y = -zaxis.y;
    rotation.m[2].z = -zaxis.z;*/
    /*rotation.m[3].x = - vec3_dot_vec3(&xaxis,position);
    rotation.m[3].y = - vec3_dot_vec3(&yaxis,position);
    rotation.m[3].z = - vec3_dot_vec3(&zaxis,position);*/

    //mat4_transpose(&rotation);

    //mat4_Log((char *)"LookAt Rot Mat",&rotation);
    // Return lookAt matrix as combination of translation and rotation matrix

    mat4_multiply_mat4(&rotation,&rotation,&translation); // Remember to read from right to left (first translation then rotation)
    return  rotation;
}

/*
   Rotate a point p by angle theta around an arbitrary axis r
   Return the rotated point.
   Positive angles are anticlockwise looking down the axis
   towards the origin.
   Assume right hand coordinate system.
*/
vec3 ArbitraryRotate(vec3 p,double theta,vec3 r)
{
    vec3 q = {0.0,0.0,0.0};
    theta = theta*DEG_TO_RAD;
    double costheta,sintheta;

    vec3_normalize(&r,&r);
    costheta = cos(theta);
    sintheta = sin(theta);

    q.x += (costheta + (1 - costheta) * r.x * r.x) * p.x;
    q.x += ((1 - costheta) * r.x * r.y - r.z * sintheta) * p.y;
    q.x += ((1 - costheta) * r.x * r.z + r.y * sintheta) * p.z;

    q.y += ((1 - costheta) * r.x * r.y + r.z * sintheta) * p.x;
    q.y += (costheta + (1 - costheta) * r.y * r.y) * p.y;
    q.y += ((1 - costheta) * r.y * r.z - r.x * sintheta) * p.z;

    q.z += ((1 - costheta) * r.x * r.z - r.y * sintheta) * p.x;
    q.z += ((1 - costheta) * r.y * r.z + r.x * sintheta) * p.y;
    q.z += (costheta + (1 - costheta) * r.z * r.z) * p.z;

    return q;
}

vec2 GFX_screenPos2DeviceCoords(int x, int y, vec2 size) {
    vec2 deviceCoords;
    deviceCoords.x = (2.0f * x) / size.x - 1.0f;
    deviceCoords.y = 1.0f - (2.0f * y) / size.y;
    return deviceCoords;
}

vec4 GFX_clipSpace2EyeCoords(vec4 clipCoords, mat4 *procetionMat) {
    mat4 inProjMat;
    mat4_copy_mat4(&inProjMat,procetionMat);
    //mat4_Log((char *)"proj Mat",&inProjMat);
    mat4_invert_full(&inProjMat);
    //mat4_Log((char *)"In proj Mat",&inProjMat);
    vec4 eyeCoods = mat4_muliply_vec4(&inProjMat,&clipCoords);
    return eyeCoods;
}

vec3 GFX_eyeCoords2WordSpace(vec4 eyeCoords, mat4 *viewMat) {
    mat4 inViewMat;
    mat4_copy_mat4(&inViewMat,viewMat);
    mat4_invert_full(&inViewMat);
    vec4 worldSpacev4 = mat4_muliply_vec4(&inViewMat,&eyeCoords);
    vec3 worldSpacev3 = {worldSpacev4.x,worldSpacev4.y,worldSpacev4.z};
    vec3_normalize(&worldSpacev3,&worldSpacev3);
    return worldSpacev3;
}

bool GFX_isPointInsideTriangle(vec3 *triangle, vec3 point) {
    vec3 p1 = triangle[0];
    vec3 p2 = triangle[1];
    vec3 p3 = triangle[2];

    //vec3_log((char *)"A p:",&p1);
    //vec3_log((char *)"B p:",&p2);
    //vec3_log((char *)"C p:",&p3);

    float a = GFX_barycentricCoord(p1,p2,p3,point);
    //float b = GFX_barycentricCoord(p2,p3,p1,point);
    //float c = GFX_barycentricCoord(p3,p1,p2,point);


    //LOGI("A:%f B:%f C:%f",a,b,c);


    //float a = GFX_barycentricCoord(p1,p2,p3,point);
    if(a>=0 && a<=1){
        float b = GFX_barycentricCoord(p2,p3,p1,point);
        if(b>=0 && b<=1){
            float c = GFX_barycentricCoord(p3,p1,p2,point);
            if(c>=0 && c<=1)
                return true;
            else return false;
        }else return false;
    }else
        return false;
    //float c = GFX_barycentricCoord(p3,p1,p2,point);

    //LOGI("A:%f B:%f C:%f",a,b,c);

    return false;
}

float GFX_barycentricCoord(vec3 a,vec3 b,vec3 c,vec3 p){
    vec3 v1;
    vec3 v2;
    vec3_diff(&v1,&b,&a);
    vec3_diff(&v2,&b,&c);

    //vec3_log((char *)"ab",&v1);
    //vec3_log((char *)"cb",&v2);

    vec3 ai;
    vec3_diff(&ai,&p,&a);
    //vec3_log((char *)"ai",&ai);
    vec3 v;
    vec3 abProj;
    vec3_project(&abProj,&v1,&v2);
    vec3_diff(&v,&v1,&abProj);

    float r = 1 - vec3_dot_vec3(&v,&ai)/vec3_dot_vec3(&v,&v1);
    return r;
}
