#ifndef MEMORY_H
#define MEMORY_H

#include "types.h"
#include "zlib/unzip.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
    #ifdef TARGET_OS_IPHONE
	//Iphone
    #include <CoreFoundation/CoreFoundation.h>
    #endif
#else
//Android
#include <android/asset_manager.h>
#endif

class memory {
public:
    #ifdef TARGET_OS_IPHONE
    #else
	static AAssetManager* mgr;
    #endif
};

typedef struct
{
	char			filename[ MAX_PATH ];
	
	unsigned int	size;
	
	unsigned int	position;

	unsigned char	*buffer;

} MEMORY;


MEMORY *mopen(const char *filename, unsigned char relative_path );

MEMORY *mclose( MEMORY *memory );

unsigned int mread( MEMORY *memory, void *dst, unsigned int size );

void minsert( MEMORY *memory, char *str, unsigned int position );

const char *getFileWithPath( CFStringRef fileName,  CFStringRef fileExtension );

#endif
