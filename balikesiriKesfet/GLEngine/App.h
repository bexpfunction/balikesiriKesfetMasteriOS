#ifdef __APPLE__
    #include "TargetConditionals.h"
    #ifdef TARGET_OS_IPHONE
    #include <OpenGLES/ES2/gl.h>
    #include <OpenGLES/ES2/glext.h>
    #endif
#endif

#include <string>
#include <stdlib.h>
#include "Logger.h"
#include "memory.h"
#include "Text3D.h"
#include "raycast.h"
#ifndef GLMINIENGINE_APP_H
#define GLMINIENGINE_APP_H

struct pinData{
public:
    int id;
    vec3 position;
    float originY;
    char *text;
    TEXT3D *text3D;
    float size;
    float fontSize;
    vec4 color;
    vec4 borderColor;
};

typedef struct
{
    void ( *Init            )( int width, int height );
    void ( *Draw            )( void );
    void ( *ToucheBegan        )( float x, float y, unsigned int tap_count );
    void ( *ToucheMoved        )( float x, float y, unsigned int tap_count );
    void ( *ToucheEnded        )( float x, float y, unsigned int tap_count );
    void ( *SetCameraRotation        )( float x, float y, float z);
    void ( *SetCameraRotationQuat    )( const quat deviceQuat );
    void ( *SetCameraRotationMatrix  )( mat4 rotationMatrix);
    void ( *SetPinDatas        )( pinData *pins,int size,float pinTextMaxOffset);
    void ( *BindCameraTexture        )( int texIdY,int texIdUV);
    void ( *InitCamera        )(float fieldOfView, float nearClip, float farClip, float smoothStep, bool enableSmooth);
    void ( *SetCameraPosition        )( float x, float y, float z);
    void ( *SetWorldScale   )( float scale);
	void ( *SetCameraSize	    )( float width, float height);
    void ( *Exit            )();
    pinData *( *GetSelectedPin )();
    //void ( *Accelerometer   )( float x, float y, float z );
} TEMPLATEAPP;

extern TEMPLATEAPP templateApp;
//Native Delegate functions for App
void AppInit(int width,int height);
void AppDraw(void);
void AppExit();
void AppToucheBegan( float x, float y, unsigned int tap_count );
void AppToucheMoved( float x, float y, unsigned int tap_count );
void AppToucheEnded( float x, float y, unsigned int tap_count );
void AppSetCameraRotation( float x, float y, float z );
void AppSetCameraRotationQuat (const quat deviceQuat);
void AppSetCameraRotationMatrix  ( mat4 rotationMatrix);
void AppSetPinDatas(pinData *pins,int size,float pinTextMaxOffset);
void AppInitCamera(float fieldOfView, float nearClip, float farClip, float smoothStep, bool enableSmooth);
void AppBindCameraTexture(int texIdY,int texIdUV);
void AppSetCameraPosition(float x,float y,float z);
void AppSetCameraSize(float width, float height);
void AppSetWorldScale(float scale);
pinData *AppGetSelectedPin();
//
void logSpecifications();
void initGL(int width,int height);//added
void initVideoCam();//added
void handleInput();
void initFont();
void initTexture();
void programDrawCallback(void *ptr);
void drawPin(pinData data);
void DrawColliderOfPin(pinData data);
void initPins();
void deletePins();
void loadModel();
void loadModelWithTOL();
void DrawCamera();
bool CheckPinHit(Raycast *ray,pinData *pin);
//void  templeteAppExit(void);

class App {
public:
    static pinData *pinDatas;
    static pinData *selectedPin;
};
#endif
