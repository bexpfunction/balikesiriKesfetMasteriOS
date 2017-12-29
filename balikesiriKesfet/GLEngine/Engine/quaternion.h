//
// Created by alp19 on 2.10.2017.
//

#ifndef XLGLMINIENGINE_QUATERNION_H
#define XLGLMINIENGINE_QUATERNION_H


#include "types.h"

class quaternion {

};

quat quaternion_fromEuler(float x,float y,float z);
quat quaternion_slerp(quat qa,quat qb,float t,float threshold);
quat quaternion_lerp(quat q1,quat q2,float time);
float quaternion_dot(quat q1,quat q2);
mat4 quaternion_quatToMat4(quat q);
mat4 quaternion_quatToViewMat(quat q);
void quaternion_quatToViewMat(mat4 *mat,quat q);
void quaternion_quatToMat4(mat4 *mat,quat q);
void quaternion_normalize(quat *q);
void quaternion_log(char * tag,quat *q);

quat operator*(quat q,float scale);
quat operator*=(quat q,float scale);
quat operator+(quat q1,quat q2);
vec3 operator*(quat q,vec3 v);


#endif //XLGLMINIENGINE_QUATERNION_H
