#include "types.h"

#ifndef GLMINIENGINE_CAMERA_H
#define GLMINIENGINE_CAMERA_H


struct  CameraSet{
public:
    float fieldOfView;
    float nearClip;
    float farClip;
    float smoothStep;
    bool enableSmooth;
};

class Camera {
private:
    vec3 position;
    vec3 rotation;
    quat rotationQuat;

    mat4 transitionMat;
    mat4 rotationMat;
    mat4 view_matrix;
    mat4 projection_matrix;
    void  createViewMatrix();

public:
    vec2 size;
    bool smoothEnabled;
    float smoothStep;
    CameraSet settings;
    mat4 view_projection_matrix;

    vec3 &getPosition();
    void setPositionRotation(const vec3 position,const vec3 rot);
    void setPosition(const vec3 &position);

    const vec3 &getRotation() const;

    void setRotation(vec3 &rotation);
    void setRotation(quat rotation);
    void rotateToTarget(const vec3 rot);
    void rotateToTargetRad(const vec3 rot);
    void rotateToTargetQuat(const quat rotQuat);

    void move(vec3 &pos);

    Camera();
    Camera(CameraSet settings,float aspectRatio);
    ~Camera();
    void setPerspective(float fovy, float aspect_ratio, float clip_start, float clip_end, float screen_orientation);
    mat4* getProjectionMatrix();

    mat4* getViewMatrix();
    vec3 forwardVec();
};


mat4 forwardMat();


#endif //GLMINIENGINE_CAMERA_H
