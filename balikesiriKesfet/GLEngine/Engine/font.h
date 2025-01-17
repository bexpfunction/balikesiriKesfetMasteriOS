/*

GFX Lightweight OpenGLES 2.0 Game and Graphics Engine

Copyright (C) 2011 Romain Marucchi-Foino http://gfx.sio2interactive.com

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the use of
this software. Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it freely,
subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim that
you wrote the original software. If you use this software in a product, an acknowledgment
in the product would be appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be misrepresented
as being the original software.

3. This notice may not be removed or altered from any source distribution.

*/


#ifndef FONT_H
#define FONT_H


#include "types.h"
#define STB_TRUETYPE_IMPLEMENTATION
#define STB_RECT_PACK_IMPLEMENTATION
#define STBTT_STATIC
#define STBRP_STATIC
#include "ttf/stb_rect_pack.h"
#include "ttf/stb_truetype.h"
#include "program.h"
#include "Camera.h"
#include "texture.h"
#include "../freetype-gl/freetype-gl.h"

typedef struct
{
	char			name[ MAX_CHAR ];

    stbtt_packedchar *character_data;
	
	float			font_size;
	
	int				texture_width;
	
	int				texture_height;
	
	int				first_character;
	
	int				count_character;
	
	PROGRAM			*program;
	
	unsigned int	tid;

    ftgl::texture_font_t *ftFont;

} FONT;


FONT *FONT_init( char *name );

FONT *FONT_free( FONT *font );

unsigned char FONT_load( FONT *font, char *filename, unsigned char relative_path, float font_size, unsigned int texture_width, unsigned int texture_height, int first_character, int count_character );
unsigned char FONT_loadFreeType( FONT *font, char *filename, unsigned char relative_path, float font_size, unsigned int texture_width, unsigned int texture_height, int first_character, int count_character );

void FONT_print( FONT *font, float x, float y, char *text, vec4 *color );

void FONT_print3D( FONT *font, TEXTURE *texture,vec3* pos, char *text, vec4 *color,Camera *cam);

float FONT_length( FONT *font, char *text );

#endif
