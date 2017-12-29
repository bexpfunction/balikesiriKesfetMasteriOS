#ifdef __APPLE__
#include "TargetConditionals.h"
#ifdef TARGET_OS_IPHONE
#include <CoreFoundation/CoreFoundation.h>
#define LOGI(fmt, ...) printf(fmt, ##__VA_ARGS__)
#endif

#else

#include <android/log.h>

#define  LOG_TAG    "GLEngine"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,LOG_TAG,__VA_ARGS__)
#endif
