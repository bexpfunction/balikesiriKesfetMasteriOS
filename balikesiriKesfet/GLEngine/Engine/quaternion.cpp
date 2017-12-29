//
// Created by alp19 on 2.10.2017.
//

#include <math.h>
#include "quaternion.h"
#include "types.h"
#include "../Logger.h"
#include "vector.h"
#include "matrix.h"

quat quaternion_fromEuler(float x, float y, float z)
{
    quat result;
    // Abbreviations for the various angular functions
    double cy = cos(y * 0.5);
    double sy = sin(y * 0.5);
    double cr = cos(z * 0.5);
    double sr = sin(z * 0.5);
    double cp = cos(x * 0.5);
    double sp = sin(x * 0.5);

    result.w = cy * cr * cp + sy * sr * sp;
    result.z = cy * sr * cp - sy * cr * sp;
    result.x = cy * cr * sp + sy * sr * cp;
    result.y = sy * cr * cp - cy * sr * sp;

    /*float angle;

    float c1 = cos(y*0.5f);
    float c2 = cos(x*0.5f);
    float c3 = cos(z*0.5f);

    float s1 = sin(y*0.5f);
    float s2 = sin(x*0.5f);
    float s3 = sin(z*0.5f);

    quat result;
    result.w = c1*c2*c3 - s1*s2*s3;
    result.z = s1*s2*c3 + c1*c2*s3;
    result.y = s1*c2*c3 + c1*s2*s3;
    result.x = c1*s2*c3 - s1*c2*s3;*/

    /*angle = x * 0.5;
    const float sr = sin(angle);
    const float cr = cos(angle);

    angle = y * 0.5;
    const float sp = sin(angle);
    const float cp = cos(angle);

    angle = z * 0.5;
    const float sy = sin(angle);
    const float cy = cos(angle);

    const float cpcy = cp * cy;
    const float spcy = sp * cy;
    const float cpsy = cp * sy;
    const float spsy = sp * sy;

    quat result;
    result.x = (sr * cpcy - cr * spsy);
    result.y = (cr * spcy + sr * cpsy);
    result.z = (cr * cpsy - sr * spcy);
    result.w = (cr * cpcy + sr * spsy);*/

    //quaternion_normalize(&result);
    return result;
}

quat quaternion_slerp(quat qa, quat qb, float t, float threshold) {
    // quaternion to return
    quat qm;
    // Calculate angle between them.
    double cosHalfTheta = qa.w * qb.w + qa.x * qb.x + qa.y * qb.y + qa.z * qb.z;

    if (cosHalfTheta < 0.0f)
    {
        qa.x = -qa.x;
        qa.y = -qa.y;
        qa.z = -qa.z;
        qa.w = -qa.w;
        cosHalfTheta = -cosHalfTheta;
    }
    // if qa=qb or qa=-qb then theta = 0 and we can return qa
    if (abs(cosHalfTheta) >= 1.0){
        qm.w = qa.w;qm.x = qa.x;qm.y = qa.y;qm.z = qa.z;
        return qm;
    }
    // Calculate temporary values.
    double halfTheta = acos(cosHalfTheta);
    double sinHalfTheta = sqrt(1.0 - cosHalfTheta*cosHalfTheta);
    // if theta = 180 degrees then result is not fully defined
    // we could rotate around any axis normal to qa or qb
    if (fabs(sinHalfTheta) < 0.001){ // fabs is floating point absolute
        qm.w = (qa.w * 0.5 + qb.w * 0.5);
        qm.x = (qa.x * 0.5 + qb.x * 0.5);
        qm.y = (qa.y * 0.5 + qb.y * 0.5);
        qm.z = (qa.z * 0.5 + qb.z * 0.5);
        return qm;
    }
    double ratioA = sin((1 - t) * halfTheta) / sinHalfTheta;
    double ratioB = sin(t * halfTheta) / sinHalfTheta;
    //calculate Quaternion.
    qm.w = (qa.w * ratioA + qb.w * ratioB);
    qm.x = (qa.x * ratioA + qb.x * ratioB);
    qm.y = (qa.y * ratioA + qb.y * ratioB);
    qm.z = (qa.z * ratioA + qb.z * ratioB);
    return qm;
    /*float angle = quaternion_dot(q1,q2);

    // make sure we use the short rotation
    if (angle < 0.0f)
    {
        q1 *= -1.0f;
        angle *= -1.0f;
    }

    /*if (angle <= (1-threshold)) // spherical interpolation
    {
        const float theta = acosf(angle);
        const float invsintheta = 1.0f/(sinf(theta));
        const float scale = sinf(theta * (1.0f-time)) * invsintheta;
        const float invscale = sinf(theta * time) * invsintheta;
        return (q1*scale) + (q2*invscale);
    /*}
    else // linear interpolation
        return quaternion_lerp(q1,q2,time);*/
}

quat quaternion_lerp(quat q1, quat q2, float time) {
    const float scale = 1.0f - time;
    return (q1*scale) + (q2*time);
}

float quaternion_dot(quat q1, quat q2) {
    return (q1.x * q2.x) + (q1.y * q2.y) + (q1.z * q2.z) + (q1.w * q2.w);
}

void quaternion_normalize(quat *q) {
    float c = 1.0f/sqrtf(q->x*q->x+q->y*q->y+q->z*q->z+q->w*q->w);
    q->x *=c;
    q->y *=c;
    q->z *=c;
    q->w *=c;
}

void quaternion_log(char *tag, quat *q) {
    LOGI("%s : x:%f y:%f z:%f w:%f",tag,q->x,q->y,q->z,q->w);
}

quat operator*(quat q, float scale) {
    quat result;
    result.x = q.x*scale;
    result.y = q.y*scale;
    result.z = q.z*scale;
    result.w = q.w*scale;
    return result;
}

quat operator*=(quat q, float scale) {
    q.x *=scale;
    q.y *=scale;
    q.z *=scale;
    q.w *=scale;
    return q;
}

quat operator+(quat q1, quat q2) {
    quat result;
    result.x = q1.x+q2.x;
    result.y = q1.y+q2.y;
    result.z = q1.z+q2.z;
    result.w = q1.w+q2.w;
    return result;
}

vec3 operator*(quat q, vec3 v) {
    vec3 uv, uuv;
    vec3 qvec = {q.x, q.y, q.z};
    vec3_cross(&uv,&qvec,&v);
    vec3_cross(&uuv,&qvec,&uv);
    uv *= (2.0f * q.w);
    uuv *= 2.0f;

    return v + uv + uuv;
}

mat4 quaternion_quatToMat4(quat q) {
    mat4 mat;
    mat4_identity(&mat);

    mat.m[0].x = 1 - 2*q.y*q.y - 2 * q.z * q.z;
    mat.m[0].y = 2*q.x*q.y + 2 * q.z * q.w;
    mat.m[0].z = 2*q.x*q.z - 2*q.y *q.w;

    mat.m[1].x = 2*q.x*q.y - 2*q.z*q.w;
    mat.m[1].y = 1 - 2*q.x*q.x - 2*q.z*q.z;
    mat.m[1].z = 2*q.y*q.z + 2 *q.x*q.w;

    mat.m[2].x = 2*q.x*q.z + 2*q.y*q.w;
    mat.m[2].y = 2*q.y*q.z - 2*q.x*q.w;
    mat.m[2].z = 1-2*q.x*q.x - 2 *q.y*q.y;

    return mat;
}

void quaternion_quatToMat4(mat4 *mat, quat q) {
    mat->m[0].x = 1 - 2*q.y*q.y - 2 * q.z * q.z;
    mat->m[0].y = 2*q.x*q.y + 2 * q.z * q.w;
    mat->m[0].z = 2*q.x*q.z - 2*q.y *q.w;

    mat->m[1].x = 2*q.x*q.y - 2*q.z*q.w;
    mat->m[1].y = 1 - 2*q.x*q.x - 2*q.z*q.z;
    mat->m[1].z = 2*q.y*q.z + 2 *q.x*q.w;

    mat->m[2].x = 2*q.x*q.z + 2*q.y*q.w;
    mat->m[2].y = 2*q.y*q.z - 2*q.x*q.w;
    mat->m[2].z = 1-2*q.x*q.x - 2 *q.y*q.y;
}

mat4 quaternion_quatToViewMat(quat q) {
    mat4 mat;
    mat4_identity(&mat);

    mat.m[0].x = 1 - 2*q.y*q.y - 2 * q.z * q.z;
    mat.m[1].x = 2*q.x*q.y + 2 * q.z * q.w;
    mat.m[2].x = 2*q.x*q.z - 2*q.y *q.w;

    mat.m[0].y = 2*q.x*q.y - 2*q.z*q.w;
    mat.m[1].y = 1 - 2*q.x*q.x - 2*q.z*q.z;
    mat.m[2].y = 2*q.y*q.z + 2 *q.x*q.w;

    mat.m[0].z = -(2*q.x*q.z + 2*q.y*q.w);
    mat.m[1].z = -(2*q.y*q.z - 2*q.x*q.w);
    mat.m[2].z = -(1-2*q.x*q.x - 2 *q.y*q.y);

    return mat;
}

void quaternion_quatToViewMat(mat4 *mat,quat q) {
    mat->m[0].x = 1 - 2*q.y*q.y - 2 * q.z * q.z;
    mat->m[1].x = 2*q.x*q.y + 2 * q.z * q.w;
    mat->m[2].x = 2*q.x*q.z - 2*q.y *q.w;

    mat->m[0].y = 2*q.x*q.y - 2*q.z*q.w;
    mat->m[1].y = 1 - 2*q.x*q.x - 2*q.z*q.z;
    mat->m[2].y = 2*q.y*q.z + 2 *q.x*q.w;

    mat->m[0].z = -(2*q.x*q.z + 2*q.y*q.w);
    mat->m[1].z = -(2*q.y*q.z - 2*q.x*q.w);
    mat->m[2].z = -(1-2*q.x*q.x - 2 *q.y*q.y);
}




