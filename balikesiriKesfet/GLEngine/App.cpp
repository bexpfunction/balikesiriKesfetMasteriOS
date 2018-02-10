//
// Created by alp19 on 5.08.2017.
//

#include "App.h"
#include "Engine/matrix.h"
#include "Engine/utils.h"
#include "Engine/types.h"
#include "Engine/vector.h"
#include "Engine/obj.h"
#include "Engine/font.h"
#include "Engine/texture.h"
#include "Engine/program.h"
#include "Engine/Text3D.h"
#include "Engine/raycast.h"
#include "Engine/GfxMath.h"
#include "Engine/quaternion.h"

#define TINYOBJLOADER_IMPLEMENTATION // define this in only *one* .cc
#include "Engine/tiny_obj_loader.h"
//#include "Callback.h" //WILL BE ADDED

vec2 screenSize;

pinData *App::pinDatas = NULL;
pinData *App::selectedPin = NULL;
int pinSize=0;
float pinTextOffset;
bool gonnaInitPins = false;
bool isPinInited = false;

TEMPLATEAPP templateApp = {
        /* Will be called once when the program start. */
        AppInit,

        /* Will be called every frame. This is the best location to plug your drawing. */
        AppDraw,

        /* This function will be triggered when a new touche is recorded on screen. */
        AppToucheBegan,

        /* This function will be triggered when an existing touche is moved on screen. */
        AppToucheMoved,
        /* This function will be triggered when an existing touche is released from the the screen. */
        AppToucheEnded,
        AppSetCameraRotation,
        AppSetCameraRotationQuat,
        AppSetCameraRotationMatrix,
        AppSetPinDatas,
        AppBindCameraTexture,
        AppInitCamera,
        AppSetCameraPosition,
        AppSetWorldScale,
        AppSetCameraSize,
        AppExit,
        *AppGetSelectedPin
};

#define  OBJ_FILE (char *) "pin_model2.obj"
#define  VERTEX_SHADER (char *) "vertex.glsl"
#define  FRAGMENT_SHADER (char *) "fragment.glsl"
#define  DEBUG_SHADER 1

CameraSet cameraSet;
PROGRAM *program = NULL;
PROGRAM *pinColliderProgram = NULL;
PROGRAM *testProgram = NULL;
PROGRAM *cameraProgram = NULL;

TEXTURE *texture = NULL;
MEMORY *m = NULL;
Camera *cam = NULL;
mat4 modelMat;
//MODEL
OBJ *obj = NULL;
OBJMESH *objmesh = NULL;

bool touchBegan = false;
vec2 touchPos;

FONT *font = NULL;
TEXT3D *text = NULL;

float worldScale = 1.0f;

const GLfloat gTriangleVertices[] = {
    0.0f, 0.414f,0,
    0.1f, -0.1f,0,
    -0.1f, -0.1f,0
};

const GLfloat glRectVertices[] = {
    -3.0f, 4.0,0,
    3.0f, 4.0f,0,
    -3.0f, 2.70f,0,
    3.0f, 4.0f,0,
    3.0f, 2.70f,0,
    -3.0f, 2.70f,0
};

int cameraTextureIdY;
int cameraTextureIdUV;

void AppToucheBegan( float x, float y, unsigned int tap_count )
{
    touchBegan = true;
    touchPos.x = x;
    touchPos.y = y;
    
    if(App::selectedPin == NULL) {
        for(int i=0;i<pinSize;i++) {
            Raycast *r = RAYCAST_createFromScreenPos(x,y,cam);
            bool hit = CheckPinHit(r,&App::pinDatas[i]);
            if(hit) {
                if(App::selectedPin != &App::pinDatas[i])
                    App::selectedPin = &App::pinDatas[i];
                else
                    App::selectedPin = NULL;
                break;
            }
        }
    } else {
        Raycast *r = RAYCAST_createFromScreenPos(x,y,cam);
        bool hit = CheckPinHit(r,App::selectedPin);
        if(!hit) {
            for(int i=0;i<pinSize;i++) {
                Raycast *r = RAYCAST_createFromScreenPos(x,y,cam);
                bool hit1 = CheckPinHit(r,&App::pinDatas[i]);
                if(hit1) {
                    if(App::selectedPin != &App::pinDatas[i])
                        App::selectedPin = &App::pinDatas[i];
                    else
                        App::selectedPin = NULL;
                    break;
                } else {
                    App::selectedPin = NULL;
                }
            }
        }
    }
}

pinData* AppGetSelectedPin(){
    return App::selectedPin;
}

void AppToucheMoved( float x, float y, unsigned int tap_count )
{

}


void AppToucheEnded( float x, float y, unsigned int tap_count )
{
    touchBegan = false;
}

mat4 deviceRotMat;
vec3 deviceRot;
quat deviceRotQuat;
quat targetRot;
void AppSetCameraRotation(float x, float y,float z){

    
    targetRot = quaternion_fromEuler(x*DEG_TO_RAD,y*DEG_TO_RAD,z*DEG_TO_RAD);
    deviceRot.x = x;
    deviceRot.y = y;
    deviceRot.z = z;
}

void AppSetCameraRotationQuat(const quat rotQ){

    deviceRotQuat = rotQ;
    targetRot = rotQ;
}
mat4 rotMat;
void AppSetCameraRotationMatrix(mat4 rotationMatrix) {
    rotMat = rotationMatrix;
}

pinData *tempPinData;
int tempPinSize;
float tempPinMaxOffset;
void AppSetPinDatas(pinData *pins,int size,float pinTextMaxOffset){

    deletePins();
    tempPinSize = size;
    tempPinMaxOffset = pinTextMaxOffset;
    tempPinData = pins;
    gonnaInitPins = true;

    
}

void AppBindCameraTexture(int texIdY,int texIdUV){
    //LOGI("AppBindCameraTexture called%d\n",texId);
    cameraTextureIdY = texIdY;
    cameraTextureIdUV = texIdUV;
}

vec2 videoCamSize;
void AppSetCameraSize(float width,float height){
    videoCamSize.x = width;
    videoCamSize.y = height;
}

static void checkGlError(const char* op) {
    for (GLint error = glGetError(); error; error = glGetError()) {
        LOGI("after %s() glError (0x%x)\n", op, error);
    }
}


const GLfloat gTriangleColors[12] = {
    1.0f, 0.0f, 0.0f, 1.0f,
    0.0f, 1.0f, 0.0f, 1.0f,
    0.0f, 0.0f, 1.0f, 1.0f
};


GLfloat *gCamUvs;

void AppInit(int width, int height) {
    screenSize.x = width;
    screenSize.y = height;
    LOGI("\n\nScreen size: %dx%d\n\n", width, height);
    logSpecifications();
    //Settings
    initGL(width,height);
    initVideoCam();
    atexit(AppExit);

    loadModelWithTOL();
    
    cam = new Camera(cameraSet,(float)width/(float)height);
    //cam = new Camera();
    //cam->setPerspective(45.0f,(float)width/(float)height,1.0f,50.0f,0);
    cam->size = screenSize;
    mat4_Log((char *)"Cam ViewMatrix",cam->getViewMatrix());LOGI("\n");
    mat4_Log((char *)"PROJECTION MATRIX",cam->getProjectionMatrix());LOGI("\n");
    
    mat4_identity(&modelMat);
 
    initFont();
}

void initGL(int width,int height){
    glEnable( GL_DEPTH_TEST );
    glEnable( GL_CULL_FACE  );
    glDisable( GL_DITHER );
    glDepthMask( GL_TRUE );
    glDepthFunc( GL_LESS );
    glDepthRangef( 0.0f, 1.0f );
    glCullFace ( GL_BACK );
    glFrontFace( GL_CW  );
    glEnable(GL_OES_standard_derivatives);
    glClearStencil( 0 );
    glStencilMask( 0xFFFFFFFF );
    glViewport(0, 0, width, height);
}

void logSpecifications(){
    const char * extensions = (char *)glGetString (GL_EXTENSIONS);
    LOGI("Vendor:%s\nRenderer:%s\nGL Version:%s\nGLSL Version:%s\nExtensions:%s",
         glGetString(GL_VENDOR),
         glGetString(GL_RENDERER),
         glGetString(GL_VERSION),
         glGetString(GL_SHADING_LANGUAGE_VERSION),
         extensions
         );
    
    int GL_OES_EGL_image_externalAvailable = (strstr((const char *)extensions, "GL_OES_EGL_image_external_essl3") != NULL);
    if(GL_OES_EGL_image_externalAvailable){
        LOGI("GL_OES_EGL_image_external is Available!");
    } else{
        LOGI("GL_OES_EGL_image_external is NOT available!");
    }
}

void initVideoCam(){
    cameraProgram = PROGRAM_create((char *)"default",(char *)"cameraVertex.glsl",(char *)"cameraFragment.glsl",1,DEBUG_SHADER,NULL,NULL);

    float camRatio = videoCamSize.y/videoCamSize.x;
    float screenRatio = screenSize.y/screenSize.x;

    //float camYRatio = screenSize.y/videoCamSize.y;
    float camYRatio = screenRatio/camRatio;
    float camOffSet = (1.0f - camYRatio)*0.5f;

    GLfloat camUvs[] = {
            camOffSet,1,    camOffSet,0,
            camYRatio+camOffSet,1,    camYRatio+camOffSet,0
    };

    gCamUvs = (GLfloat *)malloc(sizeof(GLfloat)*8);
    memcpy(gCamUvs,camUvs,sizeof(GLfloat)*8);
}

void testShape(){
    testProgram = PROGRAM_create((char *)"testProgram",(char *)"font_vertex.glsl",FRAGMENT_SHADER,1,DEBUG_SHADER,NULL,programDrawCallback);
}

unsigned int mvbo;
unsigned int mvao;
unsigned long mVertexCount;
void loadModelWithTOL(){
    program = PROGRAM_create((char *)"modelShaderProgram",VERTEX_SHADER,FRAGMENT_SHADER,1,DEBUG_SHADER,NULL,NULL);
    pinColliderProgram = PROGRAM_create((char *)"pinColliderProgram",(char *)"colorVertex.glsl",(char *)"colorFragment.glsl",1,DEBUG_SHADER,NULL,NULL);

    MEMORY *o = mopen(OBJ_FILE,1);
    
    
    if(o ){
        tinyobj::attrib_t attrib;
        std::vector<tinyobj::shape_t> shapes;
        std::vector<tinyobj::material_t> materials;
        
        std::string err;
        bool ret = tinyobj::LoadObj(&attrib, &shapes, &materials, &err,o->buffer);
        if (!err.empty()) { // `err` may contain warning message.;
            char *cstr = new char[err.length() + 1];
            strcpy(cstr, err.c_str());
            delete [] cstr;
            //LOGI("Error: %s\n",cstr);
        }
        LOGI("Model Load Complete with:%d\n",ret);
        
        unsigned char *vertex_array = NULL,*vertex_start = NULL;
        int stride=0;
        size_t size = 0;
        mVertexCount = shapes[0].mesh.num_face_vertices.size()*3;
        size = mVertexCount*(sizeof(vec3)*2);
        
        vertex_array = (unsigned char *)malloc(size);
        vertex_start = vertex_array;
        
        // Loop over shapes
        for (size_t s = 0; s < shapes.size(); s++) {
            // Loop over faces(polygon)
            size_t index_offset = 0;
            for (size_t f = 0; f < shapes[s].mesh.num_face_vertices.size(); f++) {
                int fv = shapes[s].mesh.num_face_vertices[f];
                // Loop over vertices in the face.
                for (size_t v = 0; v < fv; v++) {
                    // access to vertex
                    tinyobj::index_t idx = shapes[s].mesh.indices[index_offset + v];
                    vec3 vert;
                    vert.x = attrib.vertices[3*idx.vertex_index+0];
                    vert.y = attrib.vertices[3*idx.vertex_index+1];
                    vert.z = attrib.vertices[3*idx.vertex_index+2];
                    memcpy(vertex_array,&vert,sizeof(vec3));
                    vertex_array+=sizeof(vec3);
                    //Normals
                    vec3 norm;
                    norm.x = attrib.normals[3*idx.normal_index+0];
                    norm.y = attrib.normals[3*idx.normal_index+1];
                    norm.z = attrib.normals[3*idx.normal_index+2];
                    memcpy(vertex_array,&norm,sizeof(vec3));
                    vertex_array+=sizeof(vec3);

                }
                index_offset += fv;
                
                // per-face material
                shapes[s].mesh.material_ids[f];
            }
        }
        
        //Vertex Buffer Object
        glGenBuffers(1,&mvbo);
        glBindBuffer(GL_ARRAY_BUFFER,mvbo);
        glBufferData(GL_ARRAY_BUFFER,size,vertex_start,GL_STATIC_DRAW);
        free(vertex_start);
        glBindBuffer(GL_ARRAY_BUFFER,0);
        LOGI("Vertex BO Created\n");
        
        GLuint attribute;
        stride = sizeof(vec3)+sizeof(vec3);
        
        glGenVertexArraysOES(1,&mvao);
        //glGenVertexArrays(1,&mvao);
        glBindVertexArrayOES(mvao);
        //glBindVertexArray(mvao);
        
        LOGI("VAO Created\n");
        
        glBindBuffer(GL_ARRAY_BUFFER,mvbo);
        
        LOGI("VBO Binded\n");
        
        attribute =(GLuint)PROGRAM_get_vertex_attrib_location(program,(char *)"POSITION");
        LOGI("Position Attribute:%d\n",attribute);
        glEnableVertexAttribArray(attribute);
        glVertexAttribPointer(attribute,3,GL_FLOAT,GL_FALSE,stride,NULL);
        LOGI("Position Attribute Complete\n");
        
        attribute =(GLuint)PROGRAM_get_vertex_attrib_location(program,(char *)"NORMALS");
        LOGI("Normal Attribute:%d\n",attribute);
        glEnableVertexAttribArray(attribute);
        glVertexAttribPointer(attribute,3,GL_FLOAT,GL_FALSE,stride, BUFFER_OFFSET(sizeof(vec3)));
        LOGI("Normal Attrib Complete\n");
        
        glBindBuffer(GL_ARRAY_BUFFER,0);
        glBindVertexArrayOES(0);
        //glBindVertexArray(0);
    }
}


void loadModel(){
    program = PROGRAM_create((char *)"default",VERTEX_SHADER,FRAGMENT_SHADER,1,DEBUG_SHADER,NULL,NULL);
    pinColliderProgram = PROGRAM_create((char *)"pinColliderProgram",(char *)"colorVertex.glsl",(char *)"colorFragment.glsl",1,DEBUG_SHADER,NULL,NULL);
    //Cube
    //program = PROGRAM_create((char *)"default",(char *)"shaders/vertexColorVertex.glsl",(char *)"shaders/vertexColorFragment.glsl",1,DEBUG_SHADER,NULL,programDrawCallback);
    //return;
    obj = OBJ_load(OBJ_FILE,1);
    objmesh = &obj->objmesh[0];
    
    unsigned char *vertex_array = NULL,*vertex_start = NULL;
    int i = 0,index = 0,stride=0,size=0;
    
    //Mesh Vertex * Normal * uv
    //size = objmesh->n_objvertexdata * sizeof( vec3 ) * sizeof( vec3 ) * sizeof(vec2);
    //JustMesh
    //size = objmesh->n_objvertexdata * sizeof( vec3 );
    //Mesh And Normal
    size = objmesh->n_objvertexdata * sizeof( vec3 ) * sizeof( vec3 );
    vertex_array = (unsigned char *)malloc(size);
    vertex_start = vertex_array;
    
    for(i=0;i<objmesh->n_objvertexdata;i++){
        index = objmesh->objvertexdata[ i ].vertex_index;
        vec3 v = obj->indexed_vertex[ index ];
        memcpy( vertex_array,
               &obj->indexed_vertex[ index ],
               sizeof( vec3 ) );
        vertex_array += sizeof( vec3 );
        LOGI("%d POS %f %f %f\n",i,obj->indexed_vertex[ index ].x,obj->indexed_vertex[ index ].y,obj->indexed_vertex[ index ].z);
        //Normals
        memcpy( vertex_array,
               &obj->indexed_normal[ index ],
               sizeof( vec3 ) );
        LOGI("%d NORMAL %f %f %f\n",i,obj->indexed_normal[ index ].x,obj->indexed_normal[ index ].y,obj->indexed_normal[ index ].z);
        vertex_array += sizeof( vec3 );

    }
    
    LOGI("Vertex Array Complete\n");
    
    
    //Vertex Buffer Object
    glGenBuffers(1,&objmesh->vbo);
    glBindBuffer(GL_ARRAY_BUFFER,objmesh->vbo);
    glBufferData(GL_ARRAY_BUFFER,size,vertex_start,GL_STATIC_DRAW);
    free(vertex_start);
    glBindBuffer(GL_ARRAY_BUFFER,0);
    LOGI("Vertex BO Complete\n");
    
    ////Vertex Buffer Object for Indices
    glGenBuffers(1,&objmesh->objtrianglelist[0].vbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,objmesh->objtrianglelist[0].vbo);
    glBufferData( GL_ELEMENT_ARRAY_BUFFER,
                 objmesh->objtrianglelist[ 0 ].n_indice_array *
                 sizeof( unsigned short ),
                 objmesh->objtrianglelist[ 0 ].indice_array,
                 GL_STATIC_DRAW );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
    
    LOGI("Indices VBO Complete\n");
    
    
    GLuint attribute;
    stride = sizeof(vec3)+sizeof(vec3);
    
    glGenVertexArraysOES(1,&objmesh->vao);
    glBindVertexArrayOES(objmesh->vao);
    
    LOGI("VAO Complete\n");
    
    glBindBuffer(GL_ARRAY_BUFFER,objmesh->vbo);
    
    LOGI("VBO Bind Complete\n");
    
    attribute =(GLuint)PROGRAM_get_vertex_attrib_location(program,(char *)"POSITION");
    LOGI("Attribute:%d\n",attribute);
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute,3,GL_FLOAT,GL_FALSE,stride,NULL);
    
    LOGI("Position Attribute Complete\n");
    
    attribute =(GLuint)PROGRAM_get_vertex_attrib_location(program,(char *)"NORMALS");
    LOGI("Normal Attribute:%d\n",attribute);
    
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute,3,GL_FLOAT,GL_FALSE,stride, BUFFER_OFFSET(sizeof(vec3)));
    
    LOGI("Normal Attrib Complete\n");

    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,objmesh->objtrianglelist[0].vbo);
    LOGI("Indices VBO Bind to VAO Complete\n");
    
    glBindVertexArrayOES(0);
}

void initFont(){
    LOGI("Init Font\n");
    font = FONT_init((char *)"roboto.ttf");
    FONT_loadFreeType(font,font->name,1,72.0f,1024,1024,32,138);
    LOGI("Init Font Complete!!!\n");
}
#pragma mark-Init Pins
void initPins() {
    pinSize = tempPinSize;
    pinTextOffset = tempPinMaxOffset;
    App::pinDatas = tempPinData;
    
    for(int i=0;i<pinSize;i++) {
        //vec3 p = {App::pinDatas[i].position.x,App::pinDatas[i].position.y+3.0f,App::pinDatas[i].position.z};
        vec3 p = {0,3.0f,0};

        App::pinDatas[i].text3D = TEXT3D_init(App::pinDatas[i].text,font,p,App::pinDatas[i].fontSize/100.0f);

    }
    //LOGI("\n\nc++ pinsInited\n");
    isPinInited = true;
}

void deletePins(){
    if(pinSize>0) {
        for (int i = 0; i < pinSize; i++) {
            Text3D_free(App::pinDatas[i].text3D);
        }
        App::pinDatas = NULL;
        //free(App::pinDatas);
        pinSize = 0;
        isPinInited = false;
        //LOGI("Pins Deleted\n");
    }
}


void initTexture(){
    texture = TEXTURE_create((char *)"test",(char *)"testTex.png",1,TEXTURE_MIPMAP,TEXTURE_FILTER_2X,0.0f);
}

void programDrawCallback(void *ptr){
    
}

char uniform,attribute;
vec3 targetRotVec = {0,0,0};
void AppDraw() {

    glClearColor(0.2f,0.4f,0.5f,1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    DrawCamera();
    if(gonnaInitPins){
        //LOGI("Gonna Init pins\n");
        initPins();
        gonnaInitPins = false;
    }
    //LOGI("\n\nstaticF : %f\n\n",*statTest::staticF);
    handleInput();
    if(cam->smoothEnabled){
        cam->rotateToTargetQuat(targetRot);
    }
    
    if(isPinInited && true){
        if(App::selectedPin != NULL){
            //Draw rest first
            for(int i=pinSize-1;i>=0;i--) {
                if(App::selectedPin == &App::pinDatas[i]){
                    continue;
                }
                glDisable(GL_BLEND);
                glBindVertexArrayOES(mvao);
                PROGRAM_draw( program );
                float campos[] = {cam->getPosition().x,cam->getPosition().y,cam->getPosition().z};
                uniform = PROGRAM_get_uniform_location(program,(char *)"CAM_POS");
                glUniform3fv(uniform,1,campos);
                GLfloat f = 0;
                uniform = PROGRAM_get_uniform_location(program,(char *)"OFFSET");
                glUniform1f(uniform,f);
                
                uniform = PROGRAM_get_uniform_location(program,(char *)"PROJECTIONMATRIX");
                glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getProjectionMatrix());
                uniform = PROGRAM_get_uniform_location(program,(char *)"VIEWMAT");
                glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getViewMatrix());
                drawPin(App::pinDatas[i]);
                glBindVertexArrayOES(0);

                //Position
                modelMat.m[3].x = App::pinDatas[i].position.x * worldScale;
                modelMat.m[3].y = App::pinDatas[i].position.y + App::pinDatas[i].originY;
                modelMat.m[3].z = App::pinDatas[i].position.z * worldScale;
                //Size
                modelMat.m[0].x = App::pinDatas[i].size;
                modelMat.m[1].y = App::pinDatas[i].size;
                modelMat.m[2].z = App::pinDatas[i].size;
                
                TEXT3D_print(App::pinDatas[i].text3D,font->program,cam,&modelMat,pinTextOffset);
            }
            //Draw selected later
            glDisable(GL_BLEND);
            glBindVertexArrayOES(mvao);
            PROGRAM_draw( program );
            float campos[] = {cam->getPosition().x,cam->getPosition().y,cam->getPosition().z};
            uniform = PROGRAM_get_uniform_location(program,(char *)"CAM_POS");
            glUniform3fv(uniform,1,campos);
            GLfloat f = 0;
            uniform = PROGRAM_get_uniform_location(program,(char *)"OFFSET");
            glUniform1f(uniform,f);
            
            uniform = PROGRAM_get_uniform_location(program,(char *)"PROJECTIONMATRIX");
            glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getProjectionMatrix());
            uniform = PROGRAM_get_uniform_location(program,(char *)"VIEWMAT");
            glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getViewMatrix());
            drawPin(*App::selectedPin);
            glBindVertexArrayOES(0);
            
            //Position
            modelMat.m[3].x = App::selectedPin->position.x * worldScale;
            modelMat.m[3].y = App::selectedPin->position.y + App::selectedPin->originY;
            modelMat.m[3].z = App::selectedPin->position.z * worldScale;
            //Size
            modelMat.m[0].x = App::selectedPin->size;
            modelMat.m[1].y = App::selectedPin->size;
            modelMat.m[2].z = App::selectedPin->size;
            
            TEXT3D_print(App::selectedPin->text3D,font->program,cam,&modelMat,pinTextOffset);
        } else {
            for(int i=pinSize-1;i>=0;i--) {
                glDisable(GL_BLEND);
                glBindVertexArrayOES(mvao);
                PROGRAM_draw( program );
                float campos[] = {cam->getPosition().x,cam->getPosition().y,cam->getPosition().z};
                uniform = PROGRAM_get_uniform_location(program,(char *)"CAM_POS");
                glUniform3fv(uniform,1,campos);
                GLfloat f = 0;
                uniform = PROGRAM_get_uniform_location(program,(char *)"OFFSET");
                glUniform1f(uniform,f);
                
                uniform = PROGRAM_get_uniform_location(program,(char *)"PROJECTIONMATRIX");
                glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getProjectionMatrix());
                uniform = PROGRAM_get_uniform_location(program,(char *)"VIEWMAT");
                glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)cam->getViewMatrix());
                drawPin(App::pinDatas[i]);
                glBindVertexArrayOES(0);
                #pragma mark-Draw Texts
                //Position
                modelMat.m[3].x = App::pinDatas[i].position.x * worldScale;
                modelMat.m[3].y = App::pinDatas[i].position.y + App::pinDatas[i].originY;
                modelMat.m[3].z = App::pinDatas[i].position.z * worldScale;
                //Size
                modelMat.m[0].x = App::pinDatas[i].size;
                modelMat.m[1].y = App::pinDatas[i].size;
                modelMat.m[2].z = App::pinDatas[i].size;

                TEXT3D_print(App::pinDatas[i].text3D,font->program,cam,&modelMat,pinTextOffset);
            }
        }
    }
}
quat mq = quaternion_fromEuler(0,0,0);
void drawPin(pinData data){
    //LOGI("\n\napppinsingle x: %f y: %f z: %f\n\n",data.position.x,data.position.y,data.position.z);
    modelMat.m[3].x = data.position.x * worldScale;
    modelMat.m[3].y = data.position.y;
    modelMat.m[3].z = data.position.z * worldScale;
    
    
    modelMat.m[0].x = data.size;
    modelMat.m[1].y = data.size;
    modelMat.m[2].z = data.size;

    uniform = PROGRAM_get_uniform_location(program,(char *)"MODELMAT");
    glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)&modelMat);
    
    uniform = PROGRAM_get_uniform_location(program,(char *)"COLOR1");
    glUniform4fv(uniform,1,(float *)&data.color);
    
    uniform = PROGRAM_get_uniform_location(program,(char *)"COLOR2");
    glUniform4fv(uniform,1,(float *)&data.borderColor);
    
    
    glDrawArrays(GL_TRIANGLES,0,(int)mVertexCount);
    
}
void DrawColliderOfPin(pinData data){
    //Position
    modelMat.m[3].x = data.position.x * worldScale;
    modelMat.m[3].y = data.position.y;
    modelMat.m[3].z = data.position.z * worldScale;
    //Size
    modelMat.m[0].x = data.size;
    modelMat.m[1].y = data.size;
    modelMat.m[2].z = data.size;
    
    uniform = PROGRAM_get_uniform_location(pinColliderProgram,(char *)"MODELMAT");
    glUniformMatrix4fv(uniform,1,GL_FALSE,(float *)&modelMat);
    
    uniform = PROGRAM_get_uniform_location(pinColliderProgram,(char *)"COLOR");
    glUniform4fv(uniform,1,(float *)&data.color);
    
    //Draw Collider
    attribute = PROGRAM_get_vertex_attrib_location(pinColliderProgram,(char *)"POSITION");
    glEnableVertexAttribArray(attribute);
    
    glVertexAttribPointer(attribute,3,GL_FLOAT,GL_FALSE,0,glRectVertices);
    
    glDrawArrays(GL_TRIANGLES,0,6);

}
bool CheckPinHit(Raycast *ray,pinData *pin){
    vec3 up = {0,1,0};
    vec3 normal;
    vec3_diff(&normal,&cam->getPosition(),&pin->position);
    normal.y =0;
    vec3_normalize(&normal,&normal);
    //vec3_log((char *)"Plane Normal",&normal);
    
    
    vec3 right;
    vec3_cross(&right,&up,&normal);
    //vec3_log((char *)"Plane Right",&right);
    
    
    vec3 triangle[3];
    
    vec3 p1 = {glRectVertices[0]*right.x,glRectVertices[1],glRectVertices[2]*right.z};
    vec3 p2 = {glRectVertices[3]*right.x,glRectVertices[4],glRectVertices[5]*right.z};
    vec3 p3 = {glRectVertices[6]*right.x,glRectVertices[7],glRectVertices[8]*right.z};
    
    triangle[0] = p1;
    triangle[1] = p2;
    triangle[2] = p3;
    
    //Get Intersection point of a Plane Ray, plane normal, plane 1 position
    PlaneHit pHit = RAYCAST_planeCast(ray,&normal,&pin->position);
    if(pHit.scale<0)
        return false;

    
    modelMat.m[3].x = pin->position.x * worldScale;
    modelMat.m[3].y = pin->position.y;
    modelMat.m[3].z = pin->position.z * worldScale;
    
    modelMat.m[0].x = pin->size;
    modelMat.m[1].y = pin->size;
    modelMat.m[2].z = pin->size;
    
    vec3_multiply_mat4v2(&triangle[0],&triangle[0],&modelMat);
    vec3_multiply_mat4v2(&triangle[1],&triangle[1],&modelMat);
    vec3_multiply_mat4v2(&triangle[2],&triangle[2],&modelMat);
    
    
    bool isHit = GFX_isPointInsideTriangle(triangle,pHit.point);
    
    if(isHit)
        return true;
    vec3 p4 = {glRectVertices[9]*right.x,glRectVertices[10],glRectVertices[11]*right.z};
    vec3 p5 = {glRectVertices[12]*right.x,glRectVertices[13],glRectVertices[14]*right.z};
    vec3 p6 = {glRectVertices[15]*right.x,glRectVertices[16],glRectVertices[17]*right.z};
    
    triangle[0] = p4;
    triangle[1] = p5;
    triangle[2] = p6;
    
    vec3_multiply_mat4v2(&triangle[0],&triangle[0],&modelMat);
    vec3_multiply_mat4v2(&triangle[1],&triangle[1],&modelMat);
    vec3_multiply_mat4v2(&triangle[2],&triangle[2],&modelMat);
    
    isHit = GFX_isPointInsideTriangle(triangle,pHit.point);
    return isHit;
}


const GLfloat gCamVertices[] = {
    -1, 1,
    1, 1,
    -1, -1,
    1, -1
};

/*const GLfloat gCamUvs[] = {
 0,1,    0,0,
 0.5,1,    0.5,0
 };*/
void DrawCamera(){
    assert(cameraProgram->pid);
    glDisable( GL_DEPTH_TEST );
    glDepthMask( GL_FALSE );
    
    char uniform;
    char attribute;
    PROGRAM_draw(cameraProgram);

    
    attribute = PROGRAM_get_vertex_attrib_location(cameraProgram,(char *)"POSITION");
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute,2,GL_FLOAT,GL_FALSE,0,gCamVertices);
    
    attribute = PROGRAM_get_vertex_attrib_location(cameraProgram,(char *)"TEXCOORD0");
    glEnableVertexAttribArray(attribute);
    glVertexAttribPointer(attribute,2,GL_FLOAT,GL_FALSE,0,gCamUvs);
    
    glUniform1i( PROGRAM_get_uniform_location(cameraProgram, ( char * )"DiffuseY" ), 0 );
    glUniform1i( PROGRAM_get_uniform_location(cameraProgram, ( char * )"DiffuseUV" ), 1 );
    
  
    glActiveTexture( GL_TEXTURE0 );
    glBindTexture(GL_TEXTURE_2D,cameraTextureIdY);
    
    glActiveTexture( GL_TEXTURE1 );
    glBindTexture(GL_TEXTURE_2D,cameraTextureIdUV);                     //USING THIS INSTEAD
    glDrawArrays(GL_TRIANGLE_STRIP,0,4);
    
    glDisableVertexAttribArray(attribute);

}

void handleInput(){
    if(touchBegan && touchPos.x<screenSize.x*1/3) {
        targetRotVec.y-=2;
        vec3_log((char *)"1Target Rot:",&targetRotVec);

    }else if(touchBegan && touchPos.x>screenSize.x*2/3){
        targetRotVec.y+=2;
        vec3_log((char *)"2Target Rot:",&targetRotVec);

    }else if(touchBegan){
        if(touchPos.y<screenSize.y*1/3) {

        }else if(touchPos.y<screenSize.y*2/3){
            targetRotVec.x+=2;
            vec3_log((char *)"3Target Rot:",&targetRotVec);

        }else{
            targetRotVec.x-=2;
            vec3_log((char *)"4Target Rot:",&targetRotVec);

        }
    }
}

void debugMatricies(){
    mat4 *pm = cam->getProjectionMatrix();
    mat4 *vm = cam->getViewMatrix();
    
    mat4_Log((char *)"ViewMat",vm);
    
    mat4_Log((char *)"M",&modelMat);
    
    mat4 result;
    mat4_multiply_mat4(&result,vm,&modelMat);
    
    mat4_Log((char *)"MV",&result);
    
    mat4_multiply_mat4(&result,&result,pm);
    
    mat4_Log((char *)"MVP",&result);
}

void  AppExit(){
    pinSize = 0;
    if(program != NULL){
        SHADER_free(program->fragment_shader);
        SHADER_free(program->vertex_shader);
        PROGRAM_free(program);
    }
    if(obj != NULL)
        OBJ_free(obj);
    deletePins();
}

void AppInitCamera(float fieldOfView, float nearClip, float farClip, float smoothStep,bool enableSmooth) {
    LOGI("AppInitCamera Called. fov:%f nearClip:%f farClip:%f sStep:%f smoothEnabled:%d\n",fieldOfView,nearClip,farClip,smoothStep,enableSmooth);
    cameraSet.fieldOfView = fieldOfView;
    cameraSet.nearClip = nearClip;
    cameraSet.farClip = farClip;
    cameraSet.smoothStep = smoothStep;
    cameraSet.enableSmooth = enableSmooth;
    
}

void AppSetCameraPosition(float x, float y, float z) {
    LOGI("SetCameraPosition:%f,%f,%f\n",x,y,z);
    vec3 p = {x,y,z};
    cam->setPosition(p);
}

void AppSetWorldScale(float scale) {
	 worldScale = scale;
}
