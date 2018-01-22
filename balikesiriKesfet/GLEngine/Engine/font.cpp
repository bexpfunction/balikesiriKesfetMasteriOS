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
#include <math.h>
#include <string.h>
#include "font.h"
#include "memory.h"
#include "matrix.h"
#include "Logger.h"
#include "types.h"
#include "program.h"
#include "freetype-gl.h"

//#define  VERTEX_SHADER (char *) "shaders/font_vertex.glsl"
#define  VERTEX_SHADER (char *) "font_vertex.glsl"
//#define  FRAGMENT_SHADER (char *) "shaders/font_fragment.glsl"
#define  FRAGMENT_SHADER (char *) "font_fragment.glsl"
#define  DEBUG_SHADER 1

FONT *FONT_init(char *name )
{
	FONT *font = ( FONT * ) calloc( 1, sizeof( FONT ) );
	
	strcpy( font->name, name );

    font->program = PROGRAM_create((char *)"fontShaderProgram",VERTEX_SHADER,FRAGMENT_SHADER,1,DEBUG_SHADER,NULL,NULL);

	/*font->program = PROGRAM_init( name );
	
	font->program->vertex_shader = SHADER_init( name, GL_VERTEX_SHADER );
	
	SHADER_compile( font->program->vertex_shader,
                    "uniform mediump mat4 MODELMAT;"
                            "uniform mediump mat4 PROJECTIONMAT;"
                            "uniform mediump mat4 VIEWMAT;"
					"attribute mediump vec4 POSITION;"
					//"attribute lowp vec2 TEXCOORD0;"
					//"varying lowp vec2 texcoord0;"
					"void main( void ) {"
					//"texcoord0 = TEXCOORD0;"
					"gl_Position = PROJECTIONMAT * VIEWMAT * MODELMAT *POSITION; }",
					1 );

	font->program->fragment_shader = SHADER_init( name, GL_FRAGMENT_SHADER );
	
	SHADER_compile( font->program->fragment_shader,
					//"uniform sampler2D DIFFUSE;"
					//"uniform lowp vec4 COLOR;"
					//"varying lowp vec2 texcoord0;"
					"void main( void ) {"
					//"lowp vec4 color = texture2D( DIFFUSE, texcoord0 );"
					//"color.x = COLOR.x;"
					//"color.y = COLOR.y;"
					//"color.z = COLOR.z;"
					//"color.w *= COLOR.w;"
					"gl_FragColor = vec4(1.0,0,0,1.0); }",
					1 );

	PROGRAM_link( font->program, 0 );*/

	return font;
}


FONT *FONT_free( FONT *font )
{
	if( font->program )
	{
		SHADER_free( font->program->vertex_shader );

		SHADER_free( font->program->fragment_shader );
	
		PROGRAM_free( font->program );
	}

	if( font->character_data ) free( font->character_data );

	if( font->tid ) glDeleteTextures( 1, &font->tid );

	free( font );
	return NULL;
}


unsigned char FONT_load( FONT			*font,
						 char			*filename,
						 unsigned char	relative_path,
						 float			font_size,
						 unsigned int	texture_width,
						 unsigned int	texture_height,
						 int			first_character,
						 int			count_character )
{
	MEMORY *m = mopen( filename, relative_path );

	if( m )
	{
        int size= 1024;
        //unsigned char *texel_array = ( unsigned char * ) malloc( size * size );
        unsigned char *texel_array = ( unsigned char * ) malloc( texture_width * texture_height );

		font->character_data = ( stbtt_packedchar * ) malloc( count_character * sizeof( stbtt_packedchar ) );
		
		font->font_size = font_size;
		
		font->texture_width = texture_width;
		
		font->texture_height = texture_height;
		
		font->first_character = first_character;
		
		font->count_character = count_character;

        //static unsigned char atlas[512*512];

        ///INIT 2
        /*stbtt_fontinfo info;
        if(!stbtt_InitFont(&info,m->buffer,0)){
            LOGI("init font failed");
        }

        int b_w = 512; // bitmap width
        int b_h = 128; // bitmap height
        int l_h = 64; // line height

        // create a bitmap for the phrase
        unsigned char* bitmap =  ( unsigned char * )malloc(b_w * b_h);

        float scale = stbtt_ScaleForPixelHeight(&info, l_h);

        char* word = "how are you?";

        int x = 0;

        int ascent, descent, lineGap;
        stbtt_GetFontVMetrics(&info, &ascent, &descent, &lineGap);

        ascent *= scale;
        descent *= scale;

        int i;
        for (i = 0; i < strlen(word); ++i)
        {
            //get bounding box for character (may be offset to account for chars that dip above or below the line
            int c_x1, c_y1, c_x2, c_y2;
            stbtt_GetCodepointBitmapBox(&info, word[i], scale, scale, &c_x1, &c_y1, &c_x2, &c_y2);

            //compute y (different characters have different heights
            int y = ascent + c_y1;

            //render character (stride and offset is important here)
            int byteOffset = x + (y  * b_w);
            stbtt_MakeCodepointBitmap(&info, bitmap + byteOffset, c_x2 - c_x1, c_y2 - c_y1, b_w, scale, scale, word[i]);

            //how wide is this character
            int ax;
            stbtt_GetCodepointHMetrics(&info, word[i], &ax, 0);
            x += ax * scale;

            // add kerning
            int kern;
            kern = stbtt_GetCodepointKernAdvance(&info, word[i], word[i + 1]);
            x += kern * scale;
        }*/
        /////INIT 2 END


        static stbtt_pack_context pc;

        stbtt_PackBegin(&pc, texel_array, texture_width,texture_height,0,2,NULL);
        int s = stbtt_PackFontRange(&pc, m->buffer, 0,font_size, first_character, count_character, font->character_data);
        stbtt_PackEnd(&pc);
		LOGI("PACK FINISHED s:%d",s);
		/*stbtt_BakeFontBitmap( m->buffer,
							  0,
							  font_size,
							  texel_array,
							  texture_width,
							  texture_height,
							  first_character,
							  count_character,
							  font->character_data );*/

		mclose( m );
		
		glGenTextures(1, &font->tid );
		
		glBindTexture( GL_TEXTURE_2D, font->tid );
		
		glTexImage2D( GL_TEXTURE_2D,
					  0,
					  GL_RGBA,
					  256,
					  texture_height,
					  0,
					  GL_RGBA,
					  GL_UNSIGNED_BYTE,
                      texel_array );
		
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
		
		free( texel_array );
	}
	
	return 0;
}

unsigned char FONT_loadFreeType( FONT			*font,
						 char			*filename,
						 unsigned char	relative_path,
						 float			font_size,
						 unsigned int	texture_width,
						 unsigned int	texture_height,
						 int			first_character,
						 int			count_character )
{
	MEMORY *m = mopen( filename, relative_path );

	if( m )
	{
		ftgl::texture_atlas_t *fAtlas;

        fAtlas = ftgl::texture_atlas_new(2048,4096,1);
        font->ftFont = ftgl::texture_font_new_from_memory(fAtlas,120.0f,m->buffer,m->size);
        font->ftFont->rendermode = ftgl::RENDER_SIGNED_DISTANCE_FIELD;
        char c;
        for(int i = first_character;i<first_character+count_character;i++){

            c = i;
            ftgl::texture_font_load_glyph(font->ftFont,&c);
        }

        const char * cache = (const char *)"Çç ";

        ftgl::texture_font_load_glyphs( font->ftFont, cache );

        cache = (const char *)"Öö ";

        ftgl::texture_font_load_glyphs( font->ftFont, cache );

        cache = (const char *)"Şş ";

        ftgl::texture_font_load_glyphs( font->ftFont, cache );

        cache = (const char *)"Ğğ ";

        ftgl::texture_font_load_glyphs( font->ftFont, cache );

        cache = (const char *)"Üü ";

        ftgl::texture_font_load_glyphs( font->ftFont, cache );

        cache = (const char *)"İı ";

        ftgl::texture_font_load_glyphs( font->ftFont, cache );
        
        cache = (const char *)"âê ";
        ftgl::texture_font_load_glyphs( font->ftFont, cache );
        
        cache = (const char *)"ûô ";
        ftgl::texture_font_load_glyphs( font->ftFont, cache );
        
        cache = (const char *)"î ";
        ftgl::texture_font_load_glyphs( font->ftFont, cache );

        //char ch = 148;

        //ftgl::texture_font_load_glyph(font->ftFont,&ch);

        //ftgl::texture_glyph_t *glyph = ftgl::texture_font_get_glyph(font->ftFont,(char *)"I");

        //LOGI("s0:%f s1:%f t0:%f t1:%f",glyph->s0,glyph->s1,glyph->t0,glyph->t1);
        /*size_t minsize = 8, maxsize = 27;
        size_t count = maxsize - minsize;
        size_t i, missed = 0;

        for( i=minsize; i < maxsize; ++i )
        {
            ftgl::texture_font_t * font = ftgl::texture_font_new_from_memory(fAtlas,76,m->buffer,m->size);
            missed += texture_font_load_glyphs( font, cache );
            texture_font_delete( font );
        }*/

		glGenTextures(1, &font->tid );
		glBindTexture(GL_TEXTURE_2D , font->tid );

        glGenerateMipmap(GL_TEXTURE_2D);

        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );

        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

        glGenerateMipmap(GL_TEXTURE_2D);

        glTexImage2D( GL_TEXTURE_2D,
					  0,
					  GL_RGBA,
					  512,
					  2048,
					  0,
					  GL_RGBA,
					  GL_UNSIGNED_BYTE,
					  fAtlas->data );
        //LOGI("7");

		ftgl::texture_atlas_clear(fAtlas);
        //LOGI("8");

    }
    return 0;
}


void FONT_print( FONT *font, float x, float y, char *text, vec4 *color )
{
	char vertex_attribute =  PROGRAM_get_vertex_attrib_location( font->program,
																 ( char * )"POSITION" ),
																 
		 texcoord_attribute = PROGRAM_get_vertex_attrib_location( font->program,
																 ( char * )"TEXCOORD0" );

	//glBindVertexArrayOES( 0 );

	glBindBuffer( GL_ARRAY_BUFFER, 0 );
	
	glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );

	glDisable( GL_CULL_FACE );
	
	glDisable( GL_DEPTH_TEST );
	
	glDepthMask( GL_FALSE );

	glEnable( GL_BLEND );
		
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	
	PROGRAM_draw( font->program );

	/*glUniformMatrix4fv( PROGRAM_get_uniform_location( font->program, ( char * )"MODELVIEWPROJECTIONMATRIX"),
						1,
						GL_FALSE, 
						( float * )GFX_get_modelview_projection_matrix() );*/

	glUniform1i( PROGRAM_get_uniform_location( font->program, ( char * )"DIFFUSE" ), 0 );

	if( color ) glUniform4fv( PROGRAM_get_uniform_location( font->program, ( char * )"COLOR" ), 1, ( float * )color );

	glActiveTexture( GL_TEXTURE0 );

	glBindTexture( GL_TEXTURE_2D, font->tid );

	glEnableVertexAttribArray( vertex_attribute );
	
	glEnableVertexAttribArray( texcoord_attribute );

	while( *text )
	{
		if( *text >= font->first_character &&
			*text <= ( font->first_character + font->count_character ) )
		{
			vec2 vert[ 4 ];
			
			vec2 uv[ 4 ];
			
			stbtt_aligned_quad quad;

            stbtt_packedchar *bakedchar = font->character_data + ( *text - font->first_character );

			int round_x = floor( x + bakedchar->xoff );
			int round_y = floor( y - bakedchar->yoff );
			
			quad.x0 = ( float )round_x;
			quad.y0 = ( float )round_y;
			quad.x1 = ( float )round_x + bakedchar->x1 - bakedchar->x0;
			quad.y1 = ( float )round_y - bakedchar->y1 + bakedchar->y0;
			
			quad.s0 = bakedchar->x0 / ( float )font->texture_width;
			quad.t0 = bakedchar->y0 / ( float )font->texture_width;
			quad.s1 = bakedchar->x1 / ( float )font->texture_height;
			quad.t1 = bakedchar->y1 / ( float )font->texture_height;
			
			x += bakedchar->xadvance;
			
			vert[ 0 ].x = quad.x1; vert[ 0 ].y = quad.y0;
			uv  [ 0 ].x = quad.s1; uv  [ 0 ].y = quad.t0;

			vert[ 1 ].x = quad.x0; vert[ 1 ].y = quad.y0;
			uv  [ 1 ].x = quad.s0; uv  [ 1 ].y = quad.t0;

			vert[ 2 ].x = quad.x1; vert[ 2 ].y = quad.y1;
			uv  [ 2 ].x = quad.s1; uv  [ 2 ].y = quad.t1;

			vert[ 3 ].x = quad.x0; vert[ 3 ].y = quad.y1;
			uv  [ 3 ].x = quad.s0; uv  [ 3 ].y = quad.t1;

			glVertexAttribPointer( vertex_attribute,
								   2,
								   GL_FLOAT,
								   GL_FALSE,
								   0,
								   ( float * )&vert[ 0 ] );

			glVertexAttribPointer( texcoord_attribute,
								   2,
								   GL_FLOAT,
								   GL_FALSE,
								   0,
								   ( float * )&uv[ 0 ] );

			glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
		}
	
		++text;
	}

	glEnable( GL_CULL_FACE );
	
	glEnable( GL_DEPTH_TEST );
	
	glDepthMask( GL_TRUE );

	glDisable( GL_BLEND );
}

/*const GLfloat gTriangleVertices[] = {
        -0.5,0.5,
        0.5f, 0.5f,
        -0.5f, -0.5f,
        //0.5f, -0.5f,

        1,0.5f,
        2,0.5f,
        1,-0.5f
        //2,-0.5f
        };

const GLfloat gUvs[] = {
        0,1,
        1,1,
        0,0,
        //1,0,
        0,1,
        1,1,
        0,0
        //1,0
};*/

void FONT_print3D( FONT *font,TEXTURE *texture, vec3 *pos, char *text, vec4 *color, Camera *cam)
{
    //LOGI("text:%d",text[0]);

    glDisable(GL_CULL_FACE);

    char uniform,attribute;
    assert(font->program->pid);

    PROGRAM_draw(font->program);

    uniform = PROGRAM_get_uniform_location(font->program,(char *)"PROJECTIONMATRIX");
    glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getProjectionMatrix());

    uniform = PROGRAM_get_uniform_location(font->program,(char *)"VIEWMAT");
    glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getViewMatrix());

    uniform = PROGRAM_get_uniform_location(font->program,(char *)"MODELMAT");
    mat4 modelMat;
    mat4_identity(&modelMat);
    glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)&modelMat);

    //TEXT QUAD
    //stbtt_packedchar bakedchar = font->character_data[( text[0] - font->first_character )];
    /*int index = text[0] - font->first_character;
    stbtt_aligned_quad quad;

    LOGI("index:%d",index);
    float x = 1;
    float y = 0;
    stbtt_GetPackedQuad(font->character_data,1,1,index,&x,&y,&quad,0);*/



    //LOGI("x0;%f x1;%f\ny0;%f y1;%f\n",bakedchar.x0,bakedchar.x1,bakedchar.y0,bakedchar.y1);
    //LOGI("xOff;%f xOff2;%f\nyOff;%f yOff2;%f\n",bakedchar.xoff,bakedchar.xoff2,bakedchar.yoff,bakedchar.yoff2);
    //LOGI("xAdvance;%f",bakedchar.xadvance);
    //LOGI("x0;%f x1;%f\ny0;%f y1;%f\n",bakedchar->x0,bakedchar->x1,bakedchar->y0,bakedchar->y1);
    //LOGI("x0:%f x1:%f\ny0:%f y1:%f\ns0:%f s1:%f\nt0:%f t1:%f\n",quad.x0,quad.x1,quad.y0,quad.y1,quad.s0,quad.s1,quad.t0,quad.t1);

    /*const GLfloat gTriangleVertices[] = {
            quad.x0/7.0,0-quad.y1/7.0,
            quad.x1/7.0,0-quad.y1/7.0,
            quad.x0/7.0,quad.y0/7.0,
            quad.x1/7.0,quad.y0/7.0
    };*/
    const GLfloat gTriangleVertices[] = {
            -0.5, 0,
            0.5f, 0,
            -0.5f, -1.0f,
            0.5f, -1.0f
    };

    /*const GLfloat gUvs[] = {
            quad.s0/font->texture_width,quad.t0/font->texture_height,
            quad.s1/font->texture_width,quad.t0/font->texture_height,
            quad.s0/font->texture_width,quad.t1/font->texture_height,
            quad.s1/font->texture_width,quad.t1/font->texture_height,
    };*/


   /*const GLfloat gUvs[] = {
            quad.t0/((float)font->texture_width),1,
            quad.s0/((float)font->texture_width),1,
            quad.t0/((float)font->texture_width),0,
            quad.s0/((float)font->texture_width),0,
    };*/

    /*float x = 0;

    int l = strlen(text);
    GLfloat *textVertices = (GLfloat *)malloc(sizeof(GLfloat)*l*8);
    GLfloat *textUVs = (GLfloat *)malloc(sizeof(GLfloat)*l*8);;
    LOGI("Text length:%d",l);

    while(*text){
        ftgl::texture_glyph_t *glyph = ftgl::texture_font_get_glyph(font->ftFont,text);
        if(glyph) {
            LOGI("s0:%f s1:%f t0:%f t1:%f",glyph->s0,glyph->s1,glyph->t0,glyph->t1);
            LOGI("offsetX:%d offsetY:%d advanceX:%f advanceY:%f width:%f height:%f",glyph->offset_x,glyph->offset_y,glyph->advance_x,glyph->advance_y,(float)glyph->width,(float)glyph->height);

            const GLfloat gTriangleVertices[] = {
                    x + glyph->offset_x / 100.0f, glyph->offset_y / 100.0f + glyph->height / 100.0f,
                    x + glyph->offset_x / 100.0f + glyph->width / 100.0f,
                    glyph->offset_y / 100.0f + glyph->height / 100.0f,
                    x + glyph->offset_x / 100.0f, glyph->offset_y / 100.0f,
                    x + glyph->offset_x / 100.0f + glyph->width / 100.0f, glyph->offset_y / 100.0f
            };
            memcpy(textVertices, gTriangleVertices, sizeof(GLfloat) * 8);
            textVertices+= sizeof(GLfloat)*8;

            const GLfloat gUvs[] = {
                    glyph->s0, glyph->t0 * 2,
                    glyph->s1, glyph->t0 * 2,
                    glyph->s0, glyph->t1 * 2,
                    glyph->s1, glyph->t1 * 2
            };

            memcpy(textUVs, gUvs, sizeof(GLfloat) * 8);
            textUVs+= sizeof(GLfloat)*8;

            x += glyph->advance_x;
        }else{
            LOGI("glyph is null");
        }

        //free(&gTriangleVertices);

        //LOGI("Text:%s",text);
        text++;
    }*/
    //LOGI("copy complete");

    //LOGI("s0:%f s1:%f t0:%f t1:%f",glyph->s0,glyph->s1,glyph->t0,glyph->t1);
    //LOGI("offsetX:%d offsetY:%d advanceX:%f advanceY:%f width:%f height:%f",glyph->offset_x,glyph->offset_y,glyph->advance_x,glyph->advance_y,(float)glyph->width,(float)glyph->height);

    /*const GLfloat gUvs[] = {
            glyph->s0,glyph->t0*2,
            glyph->s1,glyph->t0*2,
            glyph->s0,glyph->t1*2,
            glyph->s1,glyph->t1*2
    };

    const GLfloat gTriangleVertices[] = {
            x+glyph->offset_x/100.0f               ,glyph->offset_y/100.0f+glyph->height/100.0f,
            x+glyph->offset_x/100.0f+glyph->width/100.0f  ,glyph->offset_y/100.0f+glyph->height/100.0f,
            x+glyph->offset_x/100.0f               ,glyph->offset_y/100.0f,
            x+glyph->offset_x/100.0f+glyph->width/100.0f  ,glyph->offset_y/100.0f
    };*/

    const GLfloat gUvs[] = {
            0,0,
            1,0,
            0,1,
            1,1
    };


    /*vert[ 0 ].x = quad.x1; vert[ 0 ].y = quad.y0;
    uv  [ 0 ].x = quad.s1; uv  [ 0 ].y = quad.t0;

    vert[ 1 ].x = quad.x0; vert[ 1 ].y = quad.y0;
    uv  [ 1 ].x = quad.s0; uv  [ 1 ].y = quad.t0;

    vert[ 2 ].x = quad.x1; vert[ 2 ].y = quad.y1;
    uv  [ 2 ].x = quad.s1; uv  [ 2 ].y = quad.t1;

    vert[ 3 ].x = quad.x0; vert[ 3 ].y = quad.y1;
    uv  [ 3 ].x = quad.s0; uv  [ 3 ].y = quad.t1;*/

    attribute = PROGRAM_get_vertex_attrib_location(font->program,(char *)"POSITION");
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute,2,GL_FLOAT,GL_FALSE,0,gTriangleVertices);

    attribute = PROGRAM_get_vertex_attrib_location(font->program,(char *)"TEXCOORD0");
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute,2,GL_FLOAT,GL_FALSE,0,gUvs);

    glUniform1i( PROGRAM_get_uniform_location( font->program, ( char * )"Diffuse" ), 0 );

    //if( color ) glUniform4fv( PROGRAM_get_uniform_location( font->program, ( char * )"COLOR" ), 1, ( float * )color );

    glActiveTexture( GL_TEXTURE0 );

    glBindTexture( GL_TEXTURE_2D, texture->tid );

    glDrawArrays(GL_TRIANGLE_STRIP,0,4);
    //glDisableVertexAttribArray(attribute);
}


float FONT_length( FONT *font, char *text )
{
	float length = 0;
	
	while( *text )
	{
		if( *text >= font->first_character &&
			*text <= ( font->first_character + font->count_character ) )
		{
            stbtt_packedchar *bakedchar = font->character_data + ( *text - font->first_character );
			
			length += bakedchar->xadvance;
		}
	
		++text;
	}
	
	return length;
}

