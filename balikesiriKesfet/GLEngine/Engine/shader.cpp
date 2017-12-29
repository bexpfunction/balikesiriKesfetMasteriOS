#ifdef __APPLE__
#include "TargetConditionals.h"
#ifdef TARGET_OS_IPHONE
//Iphone
#include <CoreFoundation/CoreFoundation.h>
#include <OpenGLES/Es2/gl.h>
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

#include <malloc/malloc.h>
#include <string.h>
#include "shader.h"
#include "../Logger.h"

SHADER *SHADER_init( char *name, unsigned int type )
{
	SHADER *shader = ( SHADER * ) calloc( 1, sizeof( SHADER ) );

	strcpy( shader->name, name );

	shader->type = type;
	
	return shader;
}


SHADER *SHADER_free( SHADER *shader )
{
	if( shader->sid ) SHADER_delete_id( shader );

	free( shader );
	return NULL;
}

 
unsigned char SHADER_compile( SHADER *shader, const char *code,int size, unsigned char debug )
{
	char type[ MAX_CHAR ] = {""};
	
	int loglen,
		status;
	
	if( shader->sid ) return 0;

	shader->sid = glCreateShader( shader->type );
    glShaderSource( shader->sid, 1,&code,(const GLint *)&size);
	
    glCompileShader( shader->sid );
    
	if( debug )
	{
        LOGI("Shader is compiling(name: %s), Debug true\n",shader->name);
		if( shader->type == GL_VERTEX_SHADER ) strcpy( type, "GL_VERTEX_SHADER" );
		else strcpy( type, "GL_FRAGMENT_SHADER" );
		
		glGetShaderiv( shader->sid, GL_INFO_LOG_LENGTH, &loglen );
		
		if( loglen )
		{
			char *log = ( char * ) malloc( loglen );

			glGetShaderInfoLog( shader->sid, loglen, &loglen, log );
			
			//#ifdef __IPHONE_4_0
			
				//printf("[ %s:%s ]\n%s\n", shader->name, type, log );
			//#else
				LOGI("[ %s:%s ]\n%s\n", shader->name, type, log );
			//#endif
			
			free( log );
        }
	}
    
    glGetShaderiv( shader->sid, GL_COMPILE_STATUS, &status );
    LOGI("Compile status: %d\n", status);
	if( !status )
	{
		SHADER_delete_id( shader );
        LOGI("Compile Failed(name: %s)!!!\n",shader->name);
		return 0;
    } else {
        LOGI("Compiled Successfully(name: %s)!!!\n",shader->name);
    }

	return 1;
}

 
void SHADER_delete_id( SHADER *shader )
{
	if( shader->sid )
	{
		glDeleteShader( shader->sid );
		shader->sid = 0;
	}
}
