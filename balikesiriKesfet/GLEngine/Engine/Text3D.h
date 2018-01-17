//
// Created by alp19 on 13.09.2017.
//

#ifndef XLGLMINIENGINE_TEXT3D_H
#define XLGLMINIENGINE_TEXT3D_H

#include "font.h"

typedef struct
{
    char			*text;

    FONT            *font;

    GLfloat         *textVertices;

    GLfloat         *textUVs;

    PROGRAM			*program;

    int             length;

    unsigned int    vbo;

    unsigned int    triVbo;

    mat4            modelMat;   //Model MAtrix

    vec3            position;
    
    float           size;
} TEXT3D;

TEXT3D * TEXT3D_init(char * text,FONT * font,vec3 pos,float size);
void TEXT3D_createTextVertices(TEXT3D *text3d);
void TEXT3D_print(TEXT3D *text,PROGRAM *program,Camera *cam,mat4 *modelMat,float maxOffset);
void TEXT3D_createModelMat(TEXT3D *text);
void TEXT3D_setPosition(TEXT3D *text,vec3 pos);
void Text3D_free(TEXT3D *text);



class Text3D {

};


#endif //XLGLMINIENGINE_TEXT3D_H
