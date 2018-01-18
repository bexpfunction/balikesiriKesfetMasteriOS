//
// Created by alp19 on 13.09.2017.
//

#include "Text3D.h"
#include "font.h"
#include "matrix.h"
#include "types.h"

TEXT3D *TEXT3D_init(char *text, FONT *font,vec3 pos,float size) {
    //LOGI("Text 3d init with text: %s\n\n", text);
    TEXT3D *text3d = (TEXT3D *)malloc(sizeof(TEXT3D));
    text3d->font = font;
    text3d->text = text;
    text3d->size = size;
    text3d->position = pos;
    text3d->program = font->program;
    //TEXT3D_setPosition(text3d,pos);
    
    TEXT3D_createTextVertices(text3d);
    
    return text3d;
}

void TEXT3D_createTextVertices(TEXT3D* text3d){
    int l = static_cast<int>(strlen(text3d->text));
    char *text =text3d->text;
    /*text = (char *)malloc(sizeof(char*)*l);
     memcpy(text,text3d->text,sizeof(char*)*l);*/
    float size = text3d->size;
    vec3 pos = text3d->position;
    
    float x = 0;
    int row = 0;
    
    
    int l2 =0;
    //while(*text){
    for(int t=0;t<l;t++){
        char c = text[t];
        //LOGI("char %c\n",c);
        //LOGI("charCode %d\n",c);
        ftgl::texture_glyph_t *glyph2 = ftgl::texture_font_get_glyph(text3d->font->ftFont,&c);
        //LOGI("codepoint %d\n",glyph2->codepoint);
        if(((int)glyph2->codepoint)>-1){
            x+= glyph2->advance_x*size;
            l2++;
        }
        //text++;
    }
    //LOGI("Length %d\n",l2);
    text3d->length = l2;
    
    int length = sizeof(vec2)*8*l2;
    
    unsigned char * vertex_array = NULL,* vertex_start = NULL;
    vertex_array = (unsigned char *)malloc(length*sizeof(unsigned char *));
    vertex_start = vertex_array;
    
    unsigned  char * ind_array = NULL, * ind_start = NULL;
    //ind_array = (unsigned char *)malloc(sizeof(unsigned short)*6*l);
    ind_array = (unsigned char *)malloc(sizeof(unsigned short)*6*l2);
    ind_start = ind_array;
    
    //text3d->textVertices = (GLfloat *)malloc(sizeof(GLfloat)*l*8);
    //text3d->textUVs = (GLfloat *)malloc(sizeof(GLfloat)*l*8);
    //GLfloat textVertices[l*8];
    //GLfloat textUVs[l*8];
    /*text3d->textVertices[l*8];
     text3d->textUVs[l*8];*/
    //LOGI("Text length:%d",l);
    
    //LOGI("length2 %d\n",l2);
    //text -= l;
    x = x*-0.5f;
    //LOGI("le%f",x);
    while(*text){
        //for(int t=0;t<l;t++){
        //char c = text[t];
        //LOGI("char %c\n",c);
        //LOGI("charCode %d\n",c);
        ftgl::texture_glyph_t *glyph = ftgl::texture_font_get_glyph(text3d->font->ftFont,text);
        
        //LOGI("ch%d\n",glyph->codepoint);
        //if(glyph) {
        if((int)glyph->codepoint>-1){
            //LOGI("s0:%f s1:%f t0:%f t1:%f\n",glyph->s0,glyph->s1,glyph->t0,glyph->t1);
            //LOGI("offsetX:%d offsetY:%d advanceX:%f advanceY:%f width:%f height:%f\n",glyph->offset_x,glyph->offset_y,glyph->advance_x,glyph->advance_y,(float)glyph->width,(float)glyph->height);
            
            float offsetY = -(float)((int)glyph->height-glyph->offset_y)*size;
            
            vec2 v;
            v.x = x + glyph->offset_x *size;
            v.y = pos.y + offsetY+glyph->height *size;
            memcpy(vertex_array,&v,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            vec2 uv = {glyph->s0, glyph->t0 * 2};
            memcpy(vertex_array,&uv,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            
            v.x = x + glyph->offset_x * size + glyph->width * size;
            v.y = pos.y + offsetY+glyph->height * size;
            memcpy(vertex_array,&v,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            uv.x = glyph->s1;
            uv.y = glyph->t0 * 2;
            memcpy(vertex_array,&uv,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            
            v.x =  x + glyph->offset_x * size;
            v.y = pos.y + offsetY;
            memcpy(vertex_array,&v,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            uv.x = glyph->s0;
            uv.y = glyph->t1 * 2;
            memcpy(vertex_array,&uv,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            
            v.x = x + glyph->offset_x * size + glyph->width * size;
            v.y = pos.y + offsetY;
            memcpy(vertex_array,&v,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            uv.x = glyph->s1;
            uv.y = glyph->t1 * 2;
            memcpy(vertex_array,&uv,sizeof(vec2));
            vertex_array+=sizeof(vec2);
            
            x += glyph->advance_x * size;
            
            int r = 4*row;  //row
            
            unsigned short ind[] = {static_cast<unsigned short>(r+0),static_cast<unsigned short>(r+1),static_cast<unsigned short>(r+2),static_cast<unsigned short>(r+1),static_cast<unsigned short>(r+3),static_cast<unsigned short>(r+2)};
            memcpy(ind_array,ind,sizeof(unsigned short)*6);
            ind_array+=sizeof(unsigned short)*6;
            row++;
        }else{
            LOGI("Unsupported or reduntant char");
        }
        text++;
        
    }
    text3d->text =NULL;
    //Vertex Buffer Object
    glGenBuffers(1,&text3d->vbo);
    glBindBuffer(GL_ARRAY_BUFFER,text3d->vbo);
    glBufferData(GL_ARRAY_BUFFER,length,vertex_start,GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER,0);
    free(vertex_start);
    //Indices Buffer Object
    glGenBuffers(1,&text3d->triVbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,text3d->triVbo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned short)*6*l2,ind_start,GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,0);
    free(ind_start);
}

void TEXT3D_print(TEXT3D *text,PROGRAM *program, Camera *cam,mat4 *modelMat,float maxOffset) {
    assert(text);
    assert(cam);
    //glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    
    char uniform,attribute;
    //assert(text->program->pid);
    if(text) {
        if (program) {
            PROGRAM_draw(program);
            
            uniform = PROGRAM_get_uniform_location(program, (char *) "PROJECTIONMATRIX");
            glUniformMatrix4fv(uniform, 1, GL_FALSE, (float *) cam->getProjectionMatrix());
            
            uniform = PROGRAM_get_uniform_location(program, (char *) "VIEWMAT");
            glUniformMatrix4fv(uniform, 1, GL_FALSE, (float *) cam->getViewMatrix());
            
            uniform = PROGRAM_get_uniform_location(program, (char *) "MODELMAT");
            glUniformMatrix4fv(uniform, 1, GL_FALSE, (float *) modelMat);
            
            float campos[] = {cam->getPosition().x, cam->getPosition().y, cam->getPosition().z};
            
            uniform = PROGRAM_get_uniform_location(program, (char *) "CAM_POS");
            glUniform3fv(uniform, 1, campos);
            
            uniform = PROGRAM_get_uniform_location(program, (char *) "OFFSET");
            glUniform1f(uniform, maxOffset);
            
            uniform = PROGRAM_get_uniform_location(program, (char *) "CAM_FAR");
            glUniform1f(uniform, cam->settings.farClip);
            
            try {
                glBindBuffer(GL_ARRAY_BUFFER, text->vbo);
                int stride = sizeof(vec2) * 2;
                //BINDING ATTRIBUTES
                attribute = PROGRAM_get_vertex_attrib_location(program, (char *) "POSITION");
                glEnableVertexAttribArray(attribute);
                //glVertexAttribPointer(attribute,2,GL_FLOAT,GL_FALSE,0,text->textVertices);
                glVertexAttribPointer(attribute, 2, GL_FLOAT, GL_FALSE, stride, NULL);
                
                attribute = PROGRAM_get_vertex_attrib_location(program, (char *) "TEXCOORD0");
                glEnableVertexAttribArray(attribute);
                glVertexAttribPointer(attribute, 2, GL_FLOAT, GL_FALSE, stride,
                                      BUFFER_OFFSET(sizeof(vec2)));
                
                glUniform1i(PROGRAM_get_uniform_location(program, (char *) "Diffuse"), 0);
                
                vec4 color = {1, 1, 1, 1};
                glUniform4fv(PROGRAM_get_uniform_location(program, (char *) "COLOR"), 1,
                             (float *) &color);
                
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, text->font->tid);
                //glDrawArrays(GL_TRIANGLE_STRIP,0,4*text->length);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, text->triVbo);
                glDrawElements(GL_TRIANGLES, 6 * text->length, GL_UNSIGNED_SHORT, (void *) NULL);
                glBindBuffer(GL_ARRAY_BUFFER, 0);
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
                glBindTexture(GL_TEXTURE_2D, 0);
            }catch (...){
                LOGI("An Exception Occured");
            }
            
            
        } else
            LOGI("TEXT3D PROGRAM ERRORRRR");
    } else
        LOGI("TEXT3D TEXT ERRORRRR");
    glDisable(GL_BLEND);
    
}

void TEXT3D_createModelMat(TEXT3D *text) {
    mat4 mat;
    mat4_identity(&mat);
    
    mat.m[3].x = text->position.x;
    mat.m[3].y = text->position.y;
    mat.m[3].z = text->position.z;
    
    text->modelMat = mat;
}

void TEXT3D_setPosition(TEXT3D *text, vec3 pos) {
    text->position = pos;
    TEXT3D_createModelMat(text);
}

void Text3D_free(TEXT3D *text) {
    LOGI("\n\n\nTEXT3D_free called!!\n\n\n");
    glDeleteBuffers(1,&text->vbo);
    glDeleteBuffers(1,&text->triVbo);
    free(text);
}
