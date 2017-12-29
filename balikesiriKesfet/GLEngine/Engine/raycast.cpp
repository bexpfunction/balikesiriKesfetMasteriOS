//
// Created by alp19 on 21.09.2017.
//

#include <malloc/malloc.h>
#include "raycast.h"
#include "GfxMath.h"
#include "../Logger.h"
#include "types.h"
#include "vector.h"

Raycast* RAYCAST_createFromScreenPos(int x, int y,Camera *cam) {
    Raycast *ray = (Raycast *)malloc(sizeof(Raycast));
    vec2 deviceCoords = GFX_screenPos2DeviceCoords(x,y,cam->size);
    //LOGI("Device Coords X:%f Y:%f",deviceCoords.x,deviceCoords.y);

    vec4 clipCoords = {deviceCoords.x, deviceCoords.y, -1.0f, 1.0f};
    vec4 eyeCoords = GFX_clipSpace2EyeCoords(clipCoords,cam->getProjectionMatrix());
    eyeCoords.z = -1;
    eyeCoords.w = 0;
    vec3 worldRay = GFX_eyeCoords2WordSpace(eyeCoords,cam->getViewMatrix());
    ray->direction = worldRay;
    ray->origin = cam->getPosition();
    //LOGI("Ray Dir x:%f y:%f z:%f",worldRay.x,worldRay.y,worldRay.z);

    return ray;
}

PlaneHit RAYCAST_planeCast(Raycast *ray, vec3 *normal, vec3 *point) {
    vec3 w;
    vec3_diff(&w,point,&ray->origin);

    float c = vec3_dot_vec3(&w,normal)/vec3_dot_vec3(&ray->direction,normal);
    //LOGI("c:%f",c);

    vec3 dVec = ray->direction*c;
    vec3_add(&dVec,&dVec,&ray->origin);
    //vec3_log((char *)"T:",&dVec);
    PlaneHit hit;
    hit.point = dVec;
    hit.scale = c;
    return hit;
}
