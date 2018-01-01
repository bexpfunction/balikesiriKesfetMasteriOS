//
//  agGL.m
//  balikesiriKesfet
//
//  Created by xloop on 26/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

#import "agGL.h"
#import "App.h"
#import "EngineBase.h"
#import "Logger.h"
#import "Reachability.h"
#import <malloc/malloc.h>
#import <AVFoundation/AVFoundation.h>

@interface agGL () <CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    Reachability *internetReachableFoo;
}

@property (nonatomic, strong) EAGLContext* context;
@property (nonatomic, strong) GLKBaseEffect* bEffect;

@property CGRect videoPreviewViewBounds;
@property AVCaptureDevice *videoDevice;
@property AVCaptureSession *captureSession;
@property dispatch_queue_t captureSessionQueue;
@property GLKView *videoPreviewView;
@property CIContext *ciContext;
@property EAGLContext *eaglContext;

@end

@implementation agGL

GLKView* glView;
#define radToDeg(x) (180.0f/M_PI)*x
#define degToRad(x) (M_PI/180.0f)*x
//For the draw test
bool checkFrameBuffer, drawTest, drawApp, glInitialized, iAvailable, locationInited, drawAppCalled;
float cPitch, cYaw, cRoll, initYaw, heading;
float rateSumX, rateSumY, rateSumZ;
NSString *curLat, *curLng, *gyroStr, *accStr, *acStr, *apStr, *arStr;
CLLocation *currentLocation;
pinData *pinList;

int pinCount = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    pinList = NULL;
    glInitialized = false;
    checkFrameBuffer = false;
    drawTest = false;
    drawApp = true;
    iAvailable = false;
    locationInited = false;

    rateSumX = degToRad(90.0f);  rateSumY = 0.0f; rateSumZ = 0.0f;
    
    [self testInternetConnection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startCameraPreview];
    
    initYaw = 0.0f;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glView = (GLKView*)self.view;
    glView.context = self.context;
    
    [EAGLContext setCurrentContext:self.context];
    
    self.bEffect = [[GLKBaseEffect alloc] init];
    //Generate framebuffer and bind to the view
    [((GLKView *) self.view) bindDrawable];
    ((GLKView *) self.view).opaque = NO;
    [((GLKView *) self.view) setBackgroundColor:[UIColor clearColor]];
    
    printf("GLSL Version = %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));
    printf("GL Version = %s\n", glGetString(GL_VERSION));
    
    
    // Do any additional setup after loading the view.
    if(checkFrameBuffer) {
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            LOGI("\nNo framebuffer!!!\n");
        else
            LOGI("\nThere IS framebuffer!!!\n");
    }

    //Get resolution
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    //TEMPLATE APP
    templateApp.InitCamera(65.0f,1.0f,1000.0f,0.5f,true);
    templateApp.Init((int)screenWidth,(int)screenHeight);
    glInitialized = true;
    
    
    //Start location manager to get current location
    
    [self startCaptureLocation];
    
    //Start motion manager for camera orientation
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0f/30.0f;
    self.motionManager.accelerometerUpdateInterval = 1.0f/30.0f;
    self.motionManager.gyroUpdateInterval = 1.0f/30.0f;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion* motion, NSError *error) {
                                                [self outputMotionData:motion];
                                            }];
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData* gyro, NSError *error) {
                                        [self outputGyroData:gyro];
                                    }];
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData* acceleration, NSError *error) {
        [self outputAccelerationData:acceleration];
    }];

    //Tap handler for the pinclick
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    //Debug rect
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 500, 370, 100)];
    infoLabel.text = @"";
    [infoLabel setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]];
    [infoLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [infoLabel setTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    [infoLabel setNumberOfLines:5];
    [self.view addSubview:infoLabel];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    printf("Memory warning!!!\n");
}

bool pInited = false;
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    drawAppCalled = false;
    if(drawApp && glInitialized) {
        templateApp.SetCameraRotation(cPitch, cYaw, cRoll);
        if(pInited) {
            templateApp.Draw();
            drawAppCalled = true;
        }
    }
    
    
    ///////////////////////////
    //Framebuffer check
    if(checkFrameBuffer) {
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            LOGI("\nNo framebuffer!!!\n");
        else
            LOGI("\nThere IS framebuffer!!!\n");
    }
}

-(void)update {
    infoLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",gyroStr,accStr,acStr,apStr,arStr];
//    [infoLabel setNumberOfLines:0]
//    [infoLabel sizeToFit];
}

//Location Manager delegates
- (void)startCaptureLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    NSLog(@"Update location started...",nil);
    
}

- (void)stopCaptureLocation
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    self.locationManager = nil;
    NSLog(@"Update location stopped...",nil);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Update Failed With Error: %@",error,nil);
}
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
    CLLocationDistance lDistance = [newLocation distanceFromLocation:oldLocation];
    if(!locationInited) {
        locationInited = true;
        curLat = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.latitude];
        curLng = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.longitude];
        [self updatePins];
        initYaw = degToRad(heading);
        pInited = true;
    }
    if(locationInited && lDistance > 100.0f){
        curLat = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.latitude];
        curLng = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.longitude];
        //[self updatePins];
        initYaw = degToRad(heading);
        pInited = true;
    }
}

- (void) tapHandler:(id)sender
{
    CGPoint location = [sender locationInView:self.view];
    CGFloat x = location.x;
    CGFloat y = location.y;

    if(glInitialized && pinCount > 0) {
        templateApp.ToucheBegan(x,y,1);
        pinData* tmpPinData;
        tmpPinData = templateApp.GetSelectedPin();
        templateApp.ToucheEnded(x,y,1);
        if(tmpPinData != NULL){
            for(int i=0; i<pinCount; i++){
                if(&pinList[i] == tmpPinData)
                    pinList[i].borderColor = {1.0f, 0.0f, 0.0f};
                else
                    pinList[i].borderColor = {1.0f, 1.0f, 1.0f};
            }
           templateApp.SetPinDatas(pinList, pinCount, 1.0f);
        }
    }
}

- (void) locationManager:(CLLocationManager *)manager
        didUpdateHeading:(CLHeading *)newHeading {
    heading = newHeading.magneticHeading; //in degrees
    cYaw = degToRad(heading);
}

-(void)outputGyroData:(CMGyroData*) gyro {
    gyroStr = [NSString stringWithFormat:@"Raw Rot rate x: %.2f y: %.2f z: %.2f",gyro.rotationRate.x, gyro.rotationRate.y, gyro.rotationRate.z];
    if(gyro.rotationRate.x > 0.005f || gyro.rotationRate.x < -0.005f) {
        rateSumX -= gyro.rotationRate.x;
        if(radToDeg(rateSumX) > 360.0f) rateSumX = degToRad(0.0f);
        if(radToDeg(rateSumX) < 0.0f) rateSumX = degToRad(360.0f);
    }
    //cPitch = rateSumX;
    //NSLog(@"pitch: %f pitchRate: %f",cPitch,gyro.rotationRate.x);
}

-(void)outputAccelerationData:(CMAccelerometerData*) acceleration {
    accStr = [NSString stringWithFormat:@"Raw Acceleration x: %.2f y: %.2f z: %.2f",acceleration.acceleration.x, acceleration.acceleration.y, acceleration.acceleration.z];
}

-(void)outputMotionData:(CMDeviceMotion*) motion {
//    CMQuaternion quat = motion.attitude.quaternion;

//    CGFloat roll  = atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z);
//    CGFloat pitch = atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z);
//    CGFloat yaw   =  asin(2*(quat.x*quat.y + quat.w*quat.z));
    
//    CGFloat pitch = atan2(2*(quat.y*quat.z + quat.w*quat.x), quat.w*quat.w - quat.x*quat.x - quat.y*quat.y + quat.z*quat.z);
//    CGFloat yaw = asin(-2*(quat.x*quat.z - quat.w*quat.y));
//    CGFloat roll = atan2(2*(quat.x*quat.y + quat.w*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z);
//
//
//    if(pitch<0.0f) pitch = degToRad(360.0f) + pitch;
//    if(roll<0.0f) roll = degToRad(360.0f) + roll;
//    if(yaw<0.0f) yaw = degToRad(360.0f) + yaw;

    apStr = [NSString stringWithFormat:@"Attitude pitch: %.2f yaw: %.2f roll: %.2f",motion.attitude.pitch, motion.attitude.yaw, motion.attitude.roll];
    arStr = [NSString stringWithFormat:@"Attitude rot rate x: %.2f y: %.2f z: %.2f",motion.rotationRate.x, motion.rotationRate.y, motion.rotationRate.z];
    acStr = [NSString stringWithFormat:@"Attitude acceleration x: %.2f y: %.2f z: %.2f",motion.userAcceleration.x, motion.userAcceleration.y, motion.userAcceleration.z];
}

-(void) updatePins {
    pInited = false;
    NSString *generatedURL = [NSString stringWithFormat:@"http://app.balikesirikesfet.com/json_distance?lat=%@&lng=%@&dis=5",curLat,curLng];
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:generatedURL]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSString* newStr = [[NSString alloc] initWithData:data
                                                                                   encoding:NSUTF8StringEncoding];
                                          // do something with the data
                                          NSData *jsonData = [newStr dataUsingEncoding:NSUTF8StringEncoding];
                                          NSError *jsError;
                                          id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsError];
                                          if (error) {
                                              NSLog(@"Error parsing JSON: %@", error);
                                          }
                                          else
                                          {
                                              //Re-init pins
                                              if ([jsonObj isKindOfClass:[NSArray class]])
                                              {
                                                  //NSLog(@"it is an array!");
                                                  NSArray *jsonArray = (NSArray *)jsonObj;
                                                  if(jsonArray.count>0 && glInitialized) {
                                                      
                                                      pinCount = jsonArray.count;
                                                      free(pinList);
                                                      pinList = (pinData*)malloc(sizeof(pinData)*jsonArray.count);
                                                      
                                                      for(int cnt=0; cnt<jsonArray.count; cnt++){
                                                          
                                                          float pLat = [(jsonArray[cnt][@"lat"]) floatValue];
                                                          float pLng = [(jsonArray[cnt][@"lng"]) floatValue];
                                                          CLLocation* tmpPinLoc = [[CLLocation alloc] initWithLatitude:pLat longitude:pLng];

                                                          pLat = (tmpPinLoc.coordinate.latitude - currentLocation.coordinate.latitude)*10000;
                                                          pLng = (tmpPinLoc.coordinate.longitude - currentLocation.coordinate.longitude)*10000;
                                                          
                                                          pinList[cnt].id = cnt;
                                                          pinList[cnt].position = {-pLat, 0.0f, pLng};
                                                          pinList[cnt].text = (char*)[(jsonArray[cnt][@"title"]) UTF8String];
                                                          pinList[cnt].size = 4.0f;
                                                          pinList[cnt].fontSize = 0.65f;
                                                          pinList[cnt].color = {0.0f, 1.0f, 0.0f, 1.0f};
                                                          pinList[cnt].borderColor = {1.0f, 1.0f, 1.0f, 1.0f};
                                                          NSLog(@"Pin text: %s posx: %f posz: %f",pinList[cnt].text,pinList[cnt].position.x,pinList[cnt].position.z);
                                                      }
                                                      templateApp.SetPinDatas(pinList,jsonArray.count,1.0f);
                                                  } else {
                                                      pinCount = 0;
                                                  }
                                              }
                                              else {
                                                  //NSLog(@"it is a dictionary");
                                                  NSDictionary *jsonDictionary = (NSDictionary *)jsonObj;
                                                  //NSLog(@"jsonDictionary - %@",jsonDictionary);
                                              }
                                          }
                                      }];
    [dataTask resume];
}

-(void) startCameraPreview {
    self.view.backgroundColor = [UIColor clearColor];
    self.eaglContext = [[EAGLContext alloc] initWithAPI:[self.context API] sharegroup:[self.context sharegroup]];
    self.videoPreviewView = [[GLKView alloc] initWithFrame:[UIScreen mainScreen].bounds context:self.eaglContext];
    self.videoPreviewView.enableSetNeedsDisplay = NO;
    self.videoPreviewView.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.videoPreviewView.frame = [UIScreen mainScreen].bounds;
    [self.view insertSubview:self.videoPreviewView atIndex:0];
    //[self.view sendSubviewToBack:_videoPreviewView];
    [self.videoPreviewView bindDrawable];
    self.videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = self.videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = self.videoPreviewView.drawableHeight;
    self.ciContext = [CIContext contextWithEAGLContext:self.eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 0)
    {
        // get the input device and also validate the settings
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDevicePosition position = AVCaptureDevicePositionBack;
        
        for (AVCaptureDevice *device in videoDevices)
        {
            if (device.position == position) {
                self.videoDevice = device;
                break;
            }
        }
        
        // obtain device input
        NSError *error = nil;
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoDevice error:&error];
        if (!videoDeviceInput)
        {
            NSLog(@"%@", [NSString stringWithFormat:@"Unable to obtain video device input, error: %@", error]);
            return;
        }
        
        // obtain the preset and validate the preset
        NSString *preset = AVCaptureSessionPresetHigh;
        if (![self.videoDevice supportsAVCaptureSessionPreset:preset])
        {
            NSLog(@"%@", [NSString stringWithFormat:@"Capture session preset not supported by video device: %@", preset]);
            return;
        }
        
        // create the capture session
        self.captureSession = [[AVCaptureSession alloc] init];
        self.captureSession.sessionPreset = preset;
        
        // CoreImage wants BGRA pixel format
        NSDictionary *outputSettings = @{ (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]};
        // create and configure video data output
        AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        videoDataOutput.videoSettings = outputSettings;
        
        // create the dispatch queue for handling capture session delegate method calls
        self.captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
        [videoDataOutput setSampleBufferDelegate:self queue:self.captureSessionQueue];
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        
        // begin configure capture session
        [self.captureSession beginConfiguration];
        
        if (![self.captureSession canAddOutput:videoDataOutput])
        {
            NSLog(@"Cannot add video data output");
            self.captureSession = nil;
            return;
        }
        
        // connect the video device input and video data and still image outputs
        [self.captureSession addInput:videoDeviceInput];
        [self.captureSession addOutput:videoDataOutput];
        
        [self.captureSession commitConfiguration];
        
        // then start everything
        [self.captureSession startRunning];
    }
    else
    {
        NSLog(@"No device with AVMediaTypeVideo");
    }
}
//AV Outputdelegate
- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    CGRect sourceExtent = sourceImage.extent;
    
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = self.videoPreviewViewBounds.size.width  / self.videoPreviewViewBounds.size.height;
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceExtent;
    if (sourceAspect > previewAspect)
    {
        // use full height of the video image, and center crop the width
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
    }
    else
    {
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
    }

    [EAGLContext setCurrentContext:self.eaglContext];
    [self.videoPreviewView bindDrawable];

    // clear eagl view to grey
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // set the blend mode to "source over" so that CI will use that
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    [self.ciContext drawImage:sourceImage inRect:self.videoPreviewViewBounds fromRect:drawRect];

    [self.videoPreviewView display];
    [EAGLContext setCurrentContext:self.context];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopAccelerometerUpdates];
    [self stopCaptureLocation];
    
    //Dealloc
    free(pinList);
}

// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    LOGI("testing connection\n");
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
            iAvailable = true;
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Someone broke the internet :(");
            iAvailable = false;
        });
    };
    
    [internetReachableFoo startNotifier];
}

@end
