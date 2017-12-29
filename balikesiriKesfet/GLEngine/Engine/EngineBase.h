//
// Created by alp19 on 5.08.2017.
//

#ifndef GLMINIENGINE_ENGINEBASE_H
#define GLMINIENGINE_ENGINEBASE_H
#ifdef __APPLE__
#include "TargetConditionals.h"
#ifdef TARGET_OS_IPHONE
//Iphone
#include <CoreFoundation/CoreFoundation.h>
//#include <OpenGLES/Es2/gl.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#endif
#else
//Android
#include <jni.h>
#include <string>
#include <android/log.h>
#include <GLES2/gl2.h>
#include <android/asset_manager.h>
#endif


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "program.h"
#include "memory.h"
#include "Camera.h"
#include "obj.h"
class EngineBase {

};
#endif //GLMINIENGINE_ENGINEBASE_H
