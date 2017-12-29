//
// Created by alp19 on 21.09.2017.
//

#ifndef XLGLMINIENGINE_RAYCAST_H
#define XLGLMINIENGINE_RAYCAST_H


#include "types.h"
#include "Camera.h"

typedef struct {
    vec3 direction;
    vec3 origin;
}Raycast;

struct PlaneHit{
    vec3 point;
    float scale;
};

Raycast *RAYCAST_createFromScreenPos(int x,int y,Camera *cam);
PlaneHit RAYCAST_planeCast(Raycast *ray,vec3 *normal,vec3 *point);


#endif //XLGLMINIENGINE_RAYCAST_H
