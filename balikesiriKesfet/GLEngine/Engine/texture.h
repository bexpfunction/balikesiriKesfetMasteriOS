#ifndef TEXTURE_H
#define TEXTURE_H

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

#include "memory.h"
#include "pngconf.h"
#include "png.h"

enum
{
	TEXTURE_CLAMP			= ( 1 << 0 ),
	TEXTURE_MIPMAP			= ( 1 << 1 ),
	TEXTURE_16_BITS			= ( 1 << 2 ),
	TEXTURE_16_BITS_5551	= ( 1 << 3 )
};


enum
{
	TEXTURE_FILTER_0X = 0,
	TEXTURE_FILTER_1X = 1,
	TEXTURE_FILTER_2X = 2,
	TEXTURE_FILTER_3X = 3
};


typedef struct
{
	unsigned int headersize;
	
	unsigned int height;

	unsigned int width;
	
	unsigned int n_mipmap;
	
	unsigned int flags;
	
	unsigned int datasize;
	
	unsigned int bpp;
	
	unsigned int bitred;

	unsigned int bitgreen;

	unsigned int bitblue;
	
	unsigned int bitalpha;
	
	unsigned int tag;
	
	unsigned int n_surface;

} PVRHEADER;


typedef struct
{
	char			name[ MAX_CHAR ];
	
	unsigned int	tid;
	
	unsigned short	width;
	
	unsigned short	height;
	
	unsigned char	byte;
	
	unsigned int	size;

	unsigned int	target;
	
	unsigned int	internal_format;
	
	unsigned int	format;

	unsigned int	texel_type;

	unsigned char	*texel_array;

	unsigned int	n_mipmap;
	
	unsigned int	compression;
		
} TEXTURE;

typedef struct {
    const int width;
    const int height;
    const int size;
    const GLenum gl_color_format;
    const void* data;
} RawImageData;

TEXTURE *TEXTURE_init( char *name );

TEXTURE *TEXTURE_free( TEXTURE *texture );

TEXTURE *TEXTURE_create( char *name, char *filename, unsigned char relative_path, unsigned int flags, unsigned char filter, float anisotropic_filter );

TEXTURE *TEXTURE_create2( char *name, char *filename);

void TEXTURE_load( TEXTURE *texture, MEMORY *memory );

void TEXTURE_load_png( TEXTURE *texture, MEMORY *memory );

void TEXTURE_load_pvr( TEXTURE *texture, MEMORY *memory );

void TEXTURE_convert_16_bits( TEXTURE *texture, unsigned char use_5551 );

void TEXTURE_generate_id( TEXTURE *texture, unsigned int flags, unsigned char filter, float anisotropic_filter );

void TEXTURE_delete_id( TEXTURE *texture );

void TEXTURE_free_texel_array( TEXTURE *texture );

void TEXTURE_draw( TEXTURE *texture );

RawImageData get_raw_image_data_from_png(png_byte* png_data, const int png_data_size);
void release_raw_image_data(const RawImageData* data);

typedef struct {
    const png_byte* data;
    const png_size_t size;
} DataHandle;

typedef struct {
    const DataHandle data;
    png_size_t offset;
} ReadDataHandle;

typedef struct {
    const png_uint_32 width;
    const png_uint_32 height;
    const int color_type;
} PngInfo;

static void read_png_data_callback(
        png_structp png_ptr, png_byte* png_data, png_size_t read_length);
static PngInfo read_and_update_info(const png_structp png_ptr, const png_infop info_ptr);
static DataHandle read_entire_png_image(
        const png_structp png_ptr, const png_infop info_ptr, const png_uint_32 height);
static GLenum get_gl_color_format(const int png_color_format);

#endif
