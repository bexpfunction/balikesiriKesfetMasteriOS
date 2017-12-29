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

@interface agGL () <CLLocationManagerDelegate> {
    Reachability *internetReachableFoo;
}

@property (nonatomic, strong) EAGLContext* context;
@property (nonatomic, strong) GLKBaseEffect* bEffect;

@end

@implementation agGL

#define radToDeg(x) (180.0f/M_PI)*x
#define degToRad(x) (M_PI/180.0f)*x
//For the draw test
bool checkFrameBuffer, drawTest, drawApp, glInitialized, iAvailable, locationInited;
float cPitch, cYaw, cRoll, initYaw, heading;
NSString *curLat, *curLng;
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

    [self testInternetConnection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // remove the view's background color; this allows us not to use the opaque property (self.view.opaque = NO) since we remove the background color drawing altogether
    self.view.backgroundColor = [UIColor clearColor];
    
    
    initYaw = 0.0f;
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView* glView = (GLKView*)self.view;
    glView.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.bEffect = [[GLKBaseEffect alloc] init];
    //Generate framebuffer and bind to the view
    [((GLKView *) self.view) bindDrawable];
    
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
#ifdef __IPHONE_6_0
    screenHeight *= 2.0f;
    screenWidth *= 2.0f;
    LOGI("\n\n\n IOS 6 \n\n\n");
#endif
    templateApp.InitCamera(65.0f,1.0f,1000.0f,0.5f,true);
    templateApp.Init((int)screenWidth,(int)screenHeight);
    glInitialized = true;
 
    
    //Start location manager to get current location
    [self startCaptureLocation];
    
    //Start motion manager for camera orientation
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 1.0f/60.0f;
    self.motionManager.accelerometerUpdateInterval = 1.0f/60.0f;
    self.motionManager.gyroUpdateInterval = 1.0f/60.0f;
    
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion* motion, NSError *error) {
                                                [self outputMotionData:motion];
                                            }];

    //Tap handler for the pinclick
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    //Debug rect
    infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 370, 40)];
    infoLabel.text = @"";
    [infoLabel setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]];
    [infoLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [infoLabel setTextColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f]];
    [self.view addSubview:infoLabel];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    printf("Memory warning!!!\n");
}

bool pInited = false;
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if(drawApp && glInitialized) {
        templateApp.SetCameraRotation(cPitch, cYaw, cRoll);
        if(pInited)
            templateApp.Draw();
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
        templateApp.ToucheEnded(x,y,1);
    }
}

- (void) locationManager:(CLLocationManager *)manager
        didUpdateHeading:(CLHeading *)newHeading {
    heading = newHeading.magneticHeading; //in degrees
    cYaw = degToRad(heading);
}

-(void)outputMotionData:(CMDeviceMotion*) motion {
    CMQuaternion quat = motion.attitude.quaternion;
    
//    CGFloat roll  = atan2(2*(quat.y*quat.w - quat.x*quat.z), 1 - 2*quat.y*quat.y - 2*quat.z*quat.z);
//    CGFloat pitch = atan2(2*(quat.x*quat.w + quat.y*quat.z), 1 - 2*quat.x*quat.x - 2*quat.z*quat.z);
//    CGFloat yaw   =  asin(2*(quat.x*quat.y + quat.w*quat.z));
    
    CGFloat pitch = atan2(2*(quat.y*quat.z + quat.w*quat.x), quat.w*quat.w - quat.x*quat.x - quat.y*quat.y + quat.z*quat.z);
    CGFloat yaw = asin(-2*(quat.x*quat.z - quat.w*quat.y));
    CGFloat roll = atan2(2*(quat.x*quat.y + quat.w*quat.z), quat.w*quat.w + quat.x*quat.x - quat.y*quat.y - quat.z*quat.z);


    if(pitch<0.0f) pitch = degToRad(360.0f) + pitch;
    if(roll<0.0f) roll = degToRad(360.0f) + roll;
    if(yaw<0.0f) yaw = degToRad(360.0f) + yaw;
    
//    cPitch = -pitch+(degToRad(90.0f)); cRoll = -roll; cYaw = -yaw;
//    cPitch = 0.0f; cRoll = 0.0f; cYaw = 0.0f;

    cPitch = degToRad(90.0f)-pitch; cRoll = 0.0f;
    infoLabel.text = [NSString stringWithFormat:@"pitch: %f yaw: %f roll: %f",
                      radToDeg(cPitch),
                      radToDeg(cYaw),
                      radToDeg(cRoll)];
}

-(void) updatePins {
    pInited = false;
    NSString *generatedURL = [NSString stringWithFormat:@"http://app.balikesirikesfet.com/json_distance?lat=%@&lng=%@&dis=20",curLat,curLng];
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
                                                          pinData* tmpPinData;
                                                          tmpPinData = templateApp.GetSelectedPin();
                                                          
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
                                                          pinList[cnt].color = {0.0f, 0.0f, 1.0f, 1.0f};
                                                          pinList[cnt].borderColor = {1.0f, 0.0f, 0.0f, 1.0f};
                                                          
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

-(void) startCameraSession {
    
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopAccelerometerUpdates];
    [self stopCaptureLocation];
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
