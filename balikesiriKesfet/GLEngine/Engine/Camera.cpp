//
// Created by alp19 on 22.08.2017.
//

#include <math.h>
#include "Camera.h"
#include "matrix.h"
#include "Logger.h"
//#include "../Logger.h"
#include "vector.h"
#include "GfxMath.h"
#include "types.h"
#include "quaternion.h"

Camera::Camera() {
    mat4_identity(&transitionMat);
    mat4_identity(&rotationMat);
    setPositionRotation(vec3_create(0.0f,0.0f,0.0f),vec3_create(0.0f,0.0f,0.0f));
    createViewMatrix();
}

Camera::Camera(CameraSet settings,float aspectRatio) {
    mat4_identity(&transitionMat);
    mat4_identity(&rotationMat);
    setPositionRotation(vec3_create(0.0f,0.0f,0.0f),vec3_create(0.0f,0.0f,0.0f));
    createViewMatrix();
    this->settings = settings;
    smoothStep = settings.smoothStep;
    smoothEnabled = settings.enableSmooth;
    setPerspective(settings.fieldOfView,aspectRatio,settings.nearClip,settings.farClip,0);
    //LOGI("Camera created: x = %f , y = %f , z = %f ,",this->position.x,this->position.y,this->position.z);
}

Camera::~Camera() {

}
void Camera::setPositionRotation(const vec3 position, const vec3 rot) {
    this->position = position;
    rotation = rot;

    transitionMat.m[3].x = -position.x;
    transitionMat.m[3].y = -position.y;
    transitionMat.m[3].z = -position.z;

    rotation.x = fmax(rotation.x,-89.99);
    rotation.x = fmin(rotation.x,89.99);
    rotationQuat = quaternion_fromEuler(rotation.x*DEG_TO_RAD,rotation.y*DEG_TO_RAD,rotation.z*DEG_TO_RAD);

    quaternion_quatToViewMat(&rotationMat,rotationQuat);
    createViewMatrix();
}

void Camera::setPerspective( float fovy, float aspect_ratio, float clip_start, float clip_end, float screen_orientation )
{
    mat4 mat;

    float d = clip_end - clip_start,
            r = ( fovy * 0.5f ) * DEG_TO_RAD,
            s = sinf( r ),
            c = cosf( r ) / s;

    LOGI("rad:%f atan:%f aspectRat:%f\n",r,c,aspect_ratio);


    mat4_identity( &mat );

    mat.m[ 0 ].x = c / aspect_ratio;
    mat.m[ 1 ].y = c;
    mat.m[ 2 ].z = -( clip_end + clip_start ) / d;
    mat.m[ 2 ].w = -1.0f;
    mat.m[ 3 ].z = -2.0f * clip_start * clip_end / d;
    mat.m[ 3 ].w =  0.0f;

    projection_matrix = mat;
    //GFX_multiply_matrix( &mat );

    //if( screen_orientation ) GFX_rotate( screen_orientation, 0.0f, 0.0f, 1.0f );
}

mat4 *Camera::getProjectionMatrix() {
    return &projection_matrix;
}

vec3 &Camera::getPosition() {
    return position;
}

void Camera::setPosition(const vec3 &position) {
    this->position = position;

    transitionMat.m[3].x = -position.x;
    transitionMat.m[3].y = -position.y;
    transitionMat.m[3].z = -position.z;
    createViewMatrix();
}

const vec3 &Camera::getRotation() const {
    return rotation;
}

void Camera::setRotation(vec3 &rotation) {
    rotation.x = fmax(rotation.x,-89.99);
    rotation.x = fmin(rotation.x,89.99);
    Camera::rotation = rotation;
    Camera::rotationQuat = quaternion_fromEuler(rotation.x*DEG_TO_RAD,rotation.y*DEG_TO_RAD,rotation.z*DEG_TO_RAD);

    quaternion_quatToViewMat(&rotationMat,Camera::rotationQuat);
    createViewMatrix();
}

void Camera::setRotationMatrix(mat4 rotationMatrix) {
    rotationMat = rotationMatrix;
    LOGI("\ncamrotmat: %f\n",rotationMat.m[1].w);
    createViewMatrix();
}

void Camera::setRotation(quat rotation) {
    Camera::rotationQuat = rotation;
    quaternion_quatToViewMat(&rotationMat,Camera::rotationQuat);
    createViewMatrix();
}

void Camera::rotateToTarget(const vec3 rot) {
    quat targetQuat = quaternion_fromEuler(rot.x*DEG_TO_RAD,rot.y*DEG_TO_RAD,rot.z*DEG_TO_RAD);
    quat cur = quaternion_slerp(Camera::rotationQuat,targetQuat,smoothStep,0.0f);
    setRotation(cur);
}

void Camera::rotateToTargetRad(const vec3 rot) {
    quat targetQuat = quaternion_fromEuler(rot.x,rot.y,rot.z);
    rotationQuat = quaternion_slerp(rotationQuat,targetQuat,smoothStep,0.0f);
    //Create Rotation Matrix of cam
    quaternion_quatToViewMat(&rotationMat,rotationQuat);
    createViewMatrix();
}

void Camera::rotateToTargetQuat(const quat rotQuat) {
    quat targetQuat = rotQuat;
    rotationQuat = quaternion_slerp(rotationQuat,targetQuat,smoothStep,0.0f);
    //Create Rotation Matrix of cam
    quaternion_quatToViewMat(&rotationMat,rotationQuat);
    createViewMatrix();
}

void Camera::move(vec3 &pos){
    vec3_add(&position,&position,&pos);
    //Update Transition Matrix
    transitionMat.m[3].x = -position.x;
    transitionMat.m[3].y = -position.y;
    transitionMat.m[3].z = -position.z;

    createViewMatrix();
}

void Camera::createViewMatrix() {
    mat4_multiply_mat4(&view_matrix,&rotationMat,&transitionMat);

    //mat4_identity(&view_matrix);
    /*vec3 t;
    vec3 f = forwardVec();
    vec3_add(&t,&position,&f);
    //vec3_log((char *)"target",&t);
    vec3 u = {0,1,0};
    u = ArbitraryRotate(u,rotation.z,f);
    view_matrix = GFX_look_at(&position,&t,&u);

    mat4_Log((char *)"Cam real view Mat",&view_matrix);
    mat4_Log((char *)"Cam Quat view Mat",&camRotationMat);*/
}

mat4 forwardMat(){
    vec3 f = {0,0,1};
    vec3 u = {0,1,0};
    vec3 r = {1,0,0};

    mat4 mat;
    mat4_identity(&mat);

    mat.m[ 0 ].x = r.x;
    mat.m[ 1 ].x = r.y;
    mat.m[ 2 ].x = r.z;

    mat.m[ 0 ].y = u.x;
    mat.m[ 1 ].y = u.y;
    mat.m[ 2 ].y = u.z;

    mat.m[ 0 ].z = -f.x;
    mat.m[ 1 ].z = -f.y;
    mat.m[ 2 ].z = -f.z;
    return  mat;
}

vec3 Camera::forwardVec(){

    vec3 forward = {0,0,1};
    vec3 up = {0,1,0};
    mat3 rotym = mat3_rotationYMat(rotation.y);
    //mat3_log((char *)"ROT Y Mat:",&rotym);

    vec3_multiply_mat3(&forward,&forward,&rotym);

    //vec3_log((char *)"forward",&forward);

    vec3 s;
    vec3_cross(&s,&forward,&up);

    //vec3_log((char *)"side",&s);

    vec3_invert(&s,&s);

    /*mat4 rotMat;
    mat4_identity(&rotMat);

    vec4 rotVec = {s.x,s.y,s.z,rotation.x};
    mat4_rotate(&rotMat,&rotMat,&rotVec);
    vec3_multiply_mat4(&forward,&forward,&rotMat);*/

     //THAT GUY TRY
    forward = ArbitraryRotate(forward,rotation.x,s);
    //vec3_log((char *)"new forward",&forward);
    //Quaternion TRY
    /*float pitch = rotation.x * RAD_TO_DEG;
    float q0 = cos(pitch/2),  q1 = sin(pitch/2)*s.x, q2 = sin(pitch/2)*s.y,  q3 = sin(pitch/2)*s.z;

    mat3 qMat = {
            (q0*q0 + q1*q1 - q2*q2 - q3*q3),2*(q2*q1 + q0*q3), 2*(q3*q1 - q0*q2),
            2*(q1*q2 - q0*q3),(q0*q0 - q1*q1 + q2*q2 - q3*q3),2*(q3*q2 + q0*q1),
            2*(q1*q3 + q0*q2),2*(q2*q3 - q0*q1),(q0*q0 - q1*q1 - q2*q2 + q3*q3)
    };

    vec3_multiply_mat3(&forward,&forward,&qMat);*/
    //vec3_multiply_mat3(&result,&forward,&resultMat);
    //vec3_multiply_mat3(&forward,&result,&rotym);
    return  forward;
}

mat4 *Camera::getViewMatrix() {
    return &view_matrix;
}

mat4 *Camera::getRotationMatrix() {
    return &rotationMat;
}
