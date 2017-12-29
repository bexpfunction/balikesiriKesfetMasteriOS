//
//  openGlIncludeTest.hpp
//  balikesiriKesfet
//
//  Created by xloop on 29/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

#ifndef openGlIncludeTest_hpp
#define openGlIncludeTest_hpp
//System specific include
#ifdef __APPLE__
    #include "TargetConditionals.h"
    #ifdef TARGET_OS_IPHONE
    #include <OpenGLES/ES2/gl.h>
    #include <OpenGLES/ES2/glext.h>
    #endif
    #elif defined _WIN32 || defined _WIN64
    #include <GL\glut.h>
#endif
//Note predefined macros(top voted answer): https://stackoverflow.com/questions/5919996/how-to-detect-reliably-mac-os-x-ios-linux-windows-in-c-preprocessor
#include <stdio.h>

#endif /* openGlIncludeTest_hpp */
class glTesting {
public:
    glTesting(int);
    float retFloat();
private:
    float hiddenF;
};


//Note cross platform example: https://stackoverflow.com/questions/18334547/how-to-use-the-same-c-code-for-android-and-ios/18334548#18334548
