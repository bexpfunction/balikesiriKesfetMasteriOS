#ifndef SHADER_H
#define SHADER_H

#include "types.h"

typedef struct
{
	char			name[ MAX_CHAR ];
	
	unsigned int	type;

	unsigned int	sid;
	
} SHADER;


SHADER *SHADER_init( char *name, unsigned int type );

SHADER *SHADER_free( SHADER *shader );

unsigned char SHADER_compile( SHADER *shader, const char *code,int size,unsigned char debug );

void SHADER_delete_id( SHADER *shader );

#endif
