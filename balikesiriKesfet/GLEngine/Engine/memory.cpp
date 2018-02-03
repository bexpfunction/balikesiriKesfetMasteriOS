#include <string.h>
#include <string>
#include <vector>
#include <stdlib.h>



#include "memory.h"
#include "../Logger.h"
#include "utils.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#include <CoreFoundation/CoreFoundation.h>
    #ifdef TARGET_OS_IPHONE
	//Iphone
	;
    #endif

#else
//Android
#include <android/asset_manager.h>
AAssetManager* memory::mgr = NULL;
#endif

//Custom
char * CFStringCopyUTF8String(CFStringRef aString) {
    if (aString == NULL) {
        return NULL;
    }
    
    CFIndex length = CFStringGetLength(aString);
    CFIndex maxSize =
    CFStringGetMaximumSizeForEncoding(length,
                                      kCFStringEncodingUTF8);
    char *buffer = (char *)malloc(maxSize);
    if (CFStringGetCString(aString, buffer, maxSize,
                           kCFStringEncodingUTF8)) {
        return buffer;
    }
    return NULL;
}



FILE *open_data_file(CFStringRef fName, CFStringRef fExt)
{
    FILE *fp;
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    if( mainBundle == NULL )
    {
        printf("unable to get main bundle\n");
        //return -1;
        return NULL;
    }

    CFURLRef dataFileURL = CFBundleCopyResourceURL(mainBundle, fName, fExt, NULL);

    if( dataFileURL == NULL )
    {
        printf("unable to locate data file: \n");
        //return -1;
        return NULL;
    }
    CFStringRef path;
    if( !CFURLCopyResourcePropertyForKey(dataFileURL, kCFURLPathKey, &path, NULL))
    {
        printf("unable to get file path: %s\n", CFStringCopyUTF8String(path));
        //return -1;
        return NULL;
    }
    
    char *pathBuffer = CFStringCopyUTF8String(path);
    fp = fopen(pathBuffer, "rb");
    free(pathBuffer);
    
    return fp;
}

const std::vector<std::string> explode(const std::string& s, const char& c)
{
    std::string buff{""};
    std::vector<std::string> v;
    
    for(auto n:s)
    {
        if(n != c) buff+=n; else
            if(n == c && buff != "") { v.push_back(buff); buff = ""; }
    }
    if(buff != "") v.push_back(buff);
    
    return v;
}

//End custom
MEMORY *mopen(const char *filename, unsigned char relative_path )
{
	#ifdef TARGET_OS_IPHONE

		FILE *f;
    
		char fname[ MAX_PATH ] = {""};
		
		if( relative_path )
		{
            
            get_file_path( getenv( "HOME" ), fname );
            
			strcat( fname, filename );
		}
		else strcpy( fname, filename );

		//f = fopen( fname, "rb" );

    std::string fN(filename);
    
    std::vector<std::string> vec{explode(fN, '.')};
    
    CFStringRef fTName, fEName;
    fTName = CFStringCreateWithCString(NULL, vec[0].c_str(), kCFStringEncodingUTF8);
    fEName = CFStringCreateWithCString(NULL, vec[1].c_str(), kCFStringEncodingUTF8);
    //LOGI("\n\nFileName:%s\nFileExtension:%s",vec[0].c_str(),vec[1].c_str());
    f = open_data_file(fTName, fEName);

    if( !f ) {
        //LOGI("\n\n\n Couldn't open with fopen..., %s \n\n\n", fname );
        return NULL;
        
    }
    
		
		MEMORY *memory = ( MEMORY * ) calloc( 1, sizeof( MEMORY ) );
		
		strcpy( memory->filename, fname );
		
		
		fseek( f, 0, SEEK_END );
		memory->size = (unsigned int)ftell( f );
		fseek( f, 0, SEEK_SET );
		
		
		memory->buffer = ( unsigned char * ) calloc( 1, memory->size + 1 );
		fread( memory->buffer, memory->size, 1, f );
		memory->buffer[ memory->size ] = 0;
		//LOGI("Size:%d FileName:%s Data:%s",memory->size, memory->filename,memory->buffer);
        //LOGI("\n\nSize:%d FileName:%s\n\n",memory->size, memory->filename);
		fclose( f );
		
		return memory;
	
	
	#else

        AAsset* asset = AAssetManager_open(memory::mgr, filename, AASSET_MODE_STREAMING);
        if (NULL == asset) {
            LOGI("_ASSET_NOT_FOUND_");
            return NULL;
        }
        long size = AAsset_getLength(asset);
		LOGI("Asset Length:%d",size);
        unsigned char* buffer = (unsigned char*) malloc (sizeof(char)*size);
        AAsset_read (asset,buffer,size);
        LOGI("%s Data:%s",filename,buffer);
        /*for(int i=0;i<size;i++){
            LOGI("Data:%c",buffer[i]);
        }*/
        AAsset_close(asset);

        MEMORY *memory = ( MEMORY * ) calloc( 1, sizeof( MEMORY ) );
        memory->buffer = buffer;
        memory->size = size;
    return  memory;
		
	#endif
}


MEMORY *mclose( MEMORY *memory )
{
	if( memory->buffer ) free( memory->buffer );
	
	free( memory );
	return NULL;
}


unsigned int mread( MEMORY *memory, void *dst, unsigned int size )
{
	if( ( memory->position + size ) > memory->size )
	{ size = memory->size - memory->position; }

	memcpy( dst, &memory->buffer[ memory->position ], size );
	
	memory->position += size;

	return size;
}


void minsert( MEMORY *memory, char *str, unsigned int position )
{
    unsigned long s1 = strlen( str );
    unsigned long s2 = memory->size + s1 + 1;

	char *buffer = ( char * )memory->buffer,
		 *tmp	 = ( char * )calloc( 1, s2 );
	
	if( position )
	{ strncpy( &tmp[ 0 ], &buffer[ 0 ], position ); }

	strcat( &tmp[ position ], str );
	
	strcat( &tmp[ position + s1 ], &buffer[ position ] );

	memory->size = (unsigned int)s2;
	
	free( memory->buffer );
	memory->buffer = ( unsigned char * )tmp;	
}


const char *getFileWithPath( CFStringRef fileName,  CFStringRef fileExtension) {
    //Get the complete path with file name
    // Get a reference to the main bundle
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    
    // Get a reference to the file's URL
    CFURLRef fileURL = CFBundleCopyResourceURL(mainBundle, fileName, fileExtension, NULL);
    
    // Convert the URL reference into a string reference
    CFStringRef filePath = CFURLCopyFileSystemPath(fileURL, kCFURLPOSIXPathStyle);
    
    // Get the system encoding method
    CFStringEncoding encodingMethod = CFStringGetSystemEncoding();
    
    // Convert the string reference into a C string
    const char *path = CFStringGetCStringPtr(filePath, encodingMethod);
    return path;
}
