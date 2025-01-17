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
#import <string>
#import <malloc/malloc.h>
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>
#import "SWRevealViewController.h"
#import <SceneKit/SceneKit.h>
#import "quaternion.h"
#import "objcPinPicCell.h"
#import "balikesiriKesfet-swift.h"

@interface agGL () <CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UICollectionViewDelegate, SWRevealViewControllerDelegate> {
    Reachability *internetReachableFoo;
}

@property (nonatomic, strong) EAGLContext* context;
@property (nonatomic, strong) GLKBaseEffect* bEffect;

@end

//AllGlobals and definitions
#pragma mark - Custom macros
#define radToDeg(x) (180.0f/M_PI)*x
#define degToRad(x) (M_PI/180.0f)*x
#define kFilteringFactor 0.1
#define sensorUpdateRate (1.0f/30.0f)
#define SENSOR_ORIENTATION [[UIApplication sharedApplication] statusBarOrientation] //enum  1(NORTH)  2(SOUTH)  3(EAST)  4(WEST)

#pragma mark - Global Bools
bool checkFrameBuffer, drawTest, drawApp, glInitialized, iAvailable, locationInited, drawAppCalled, pinInfoViewOpened = false;
bool annotationOpened = false;
#pragma mark - Global floats
float cPitch, cYaw, cRoll, initYaw, heading, motionLastYaw=0.0f, startingHeading, updatingHeading, startHeadingOffset;
#pragma mark - Global Strings
NSString *curLat, *curLng, *model;
#pragma mark - Global Locations
CLLocation *currentLocation, *averageLocation;
//CLLocation* closestPinLoc, *furthestPinLoc;
#pragma mark - Global pinList
static pinData* pinList = NULL;
#pragma mark - Globals ints
int pinCount = 0, selectedPinId = -1;
quat deviceQuat;
NSMutableArray *constTextList;
NSMutableArray *constAnimTextList;
NSMutableArray *constAnimStates;
NSMutableArray *constDescrpList;
NSMutableArray *constDistanceList;
NSMutableArray *constPinLatList;
NSMutableArray *constPinLngList;
NSMutableArray *constPinImageList;
NSMutableArray *constPinGalleryImages;
NSMutableArray *constPinOriginY;
NSMutableArray *constPinIsAnimated;
NSMutableArray *constPinTypes;
NSMutableArray *constPinWillRendered;
NSMutableArray *constGlobalBearingOffsets;
#pragma mark UserDefaults
NSUserDefaults *pinDefaults;

@implementation agGL {
    
#pragma mark - AVFoundation Variables
    AVCaptureSession* captureSession;
    CVOpenGLESTextureCacheRef _videoTextureCache;
    CVOpenGLESTextureRef camTextureRefY;
    CVOpenGLESTextureRef camTextureRefUV;
    
#pragma mark - GL view
    GLKView* glView;
    
}

#pragma mark - ViewController Methods And Delegates
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Get the model
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    model = [defaults stringForKey:@"currentDeviceModel"];
    NSLog(@" model %@" , model);
    
    //Setup side menu
    [self.openMenuBut setTarget:self.revealViewController];
    [self.openMenuBut setAction:@selector(revealToggle:)];
    self.revealViewController.rearViewRevealWidth = 240;
    self.revealViewController.rearViewRevealOverdraw = 300;
    self.revealViewController.delegate = self;
    //[self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    //[self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.tapGestureRecognizer];

    glInitialized = false;
    checkFrameBuffer = false;
    drawTest = false;
    drawApp = true;
    iAvailable = false;
    locationInited = false;
    self.crosshairImag.alpha = 0.0f;
    
    //Setup annotationPopup
    self.annotationPopup.layer.cornerRadius = 5;
    self.annotationPopup.layer.borderWidth = 1;
    self.annotationPopup.layer.borderColor = UIColor.whiteColor.CGColor;
    self.annotationExitBut.layer.cornerRadius = 5;
    self.annotationExitBut.layer.borderWidth = 1;
    self.annotationExitBut.layer.borderColor = UIColor.whiteColor.CGColor;
    self.showOnMapBut.layer.cornerRadius = 5;
    self.showOnMapBut.layer.borderWidth = 1;
    self.showOnMapBut.layer.borderColor = UIColor.whiteColor.CGColor;
    self.galleryColView.delegate = self;
    if([model isEqualToString:@"iPhone 5c"] || [model isEqualToString:@"iPhone SE"] || [model isEqualToString:@"iPhone 5s"] || [model isEqualToString:@"iPhone 5"]){
        NSLog(@"model worked %@", model);
        CGRect newFrame = self.annotationPopup.frame;
        newFrame.size.width = newFrame.size.width * 0.8516;
        newFrame.size.height = newFrame.size.height * 0.8516;
        [self.annotationPopup setFrame:newFrame];
        
        newFrame = self.pinInfoView.frame;
        newFrame.size.width = newFrame.size.width * 0.8516;
        newFrame.size.height = newFrame.size.height * 0.8516;
        [self.pinInfoView setFrame:newFrame];
    }
    
    //Setup pininfoview
    self.pinInfoBg.layer.cornerRadius = 5;
    self.pinInfoBg.layer.borderColor = UIColor.whiteColor.CGColor;
    self.pinInfoBg.layer.borderWidth = 1;
    self.pinInfoDetailBut.layer.cornerRadius = 5;
    self.pinInfoDetailBut.layer.borderWidth = 1;
    self.pinInfoDetailBut.layer.borderColor = UIColor.whiteColor.CGColor;
    
    //Fill const arrays
    constTextList         = [[NSMutableArray alloc]init];
    constDistanceList     = [[NSMutableArray alloc]init];
    constDescrpList       = [[NSMutableArray alloc]init];
    constPinLatList       = [[NSMutableArray alloc]init];
    constPinLngList       = [[NSMutableArray alloc]init];
    constPinImageList     = [[NSMutableArray alloc]init];
    constPinGalleryImages = [[NSMutableArray alloc]init];
    constAnimTextList     = [[NSMutableArray alloc]init];
    constAnimStates       = [[NSMutableArray alloc]init];
    constPinOriginY       = [[NSMutableArray alloc]init];
    constPinIsAnimated    = [[NSMutableArray alloc]init];
    constGlobalBearingOffsets = [[NSMutableArray alloc]init];
    constPinTypes         = [[NSMutableArray alloc]init];
    constPinWillRendered = [[NSMutableArray alloc]init];
    pinDefaults = [NSUserDefaults standardUserDefaults];
    
    [self testInternetConnection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    initYaw = 0.0f;
    
    //Start location manager to get current location
    [self startCaptureLocation];
    
    //Init engine
    [self initTemplateAppWithGL];
    [self startCameraPreview];
    
    //Start motion manager for camera orientation
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = sensorUpdateRate;
    self.motionManager.accelerometerUpdateInterval = sensorUpdateRate;
    self.motionManager.gyroUpdateInterval = sensorUpdateRate;
  
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        [self outputMotionData:motion];
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.5f repeats:true block:^(NSTimer * _Nonnull timer) {
        [self animateTexts];
    }];
    
    [NSTimer scheduledTimerWithTimeInterval:0.01f repeats:true block:^(NSTimer * _Nonnull timer) {
        [self updatePinPositions];
    }];

    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    self.crosshairImag.alpha = 1.0f;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    printf("Memory warning!!!\n");
}

-(void) initTemplateAppWithGL {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    glView = (GLKView*)self.view;
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
    
    //Get device
    //NSLog(@"current device: %@",[[UIDevice currentDevice] model]);
    NSLog(@"current device: %@",[[NSUUID UUID] UUIDString]);
    
    //Get resolution
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width ;
    CGFloat screenHeight = screenRect.size.height;

    //TEMPLATE APP
    templateApp.SetCameraSize(1080.0f,1920.0f);
    templateApp.InitCamera(65.0f,0.01f,10.0f,0.5f,true);
    templateApp.Init((int)screenWidth * (int)UIScreen.mainScreen.scale,(int)screenHeight * (int)UIScreen.mainScreen.scale);
    glInitialized = true;
}

bool pInited = false;
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    drawAppCalled = false;

    if(drawApp && glInitialized) {

        templateApp.SetCameraRotationQuat(deviceQuat);
        if(pInited) {
            if((int)pinCount>0 && pinList != NULL){
                
                //Check for pin on crosshair
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                CGFloat screenWidth = screenRect.size.width ;
                CGFloat screenHeight = screenRect.size.height;
                templateApp.ToucheBegan(screenWidth * UIScreen.mainScreen.scale / 2.0f,screenHeight * UIScreen.mainScreen.scale / 2.0f,1);
                templateApp.ToucheEnded(screenWidth * UIScreen.mainScreen.scale / 2.0f,screenHeight * UIScreen.mainScreen.scale / 2.0f,1);
                
                selectedPinId = -1;
                if(templateApp.GetSelectedPin() != NULL) {
                    for(int i=0; i<pinCount; i++) {
                        if(&pinList[i] == templateApp.GetSelectedPin()) {
                            pinList[i].borderColor = {0.0f, 0.52f, 1.0f, 1.0f};
                            selectedPinId = pinList[i].id;
                        }
                        else {
                            pinList[i].borderColor = {0.14f, 0.30f, 0.43f, 1.0f};
                        }
                    }
                    
                    //Bring pininfo view
                    if(selectedPinId >= 0) {
                        //self.pinInfoTitle.text = constDescrpList[selectedPinId];
                        self.pinInfoTitle.text = constTextList[selectedPinId];
                        self.pinInfoDistance.text = constDistanceList[selectedPinId];
                    }
                    if(pinInfoViewOpened == false)
                        [self pinInfoViewIn];
                } else {
                    selectedPinId = -1;
                    for(int i=0; i<pinCount; i++) {
                        pinList[i].borderColor = {0.14f, 0.30f, 0.43f, 1.0f};
                    }
                    //Remove pininfo view withtimer
                    if(pinInfoViewOpened == true){
                        [NSTimer scheduledTimerWithTimeInterval:3.0f repeats:false block:^(NSTimer * _Nonnull timer) {
                            [self controlPopupVisibility];
                        }];
                        //[self pinInfoViewOut];
                    }
                }
            }
            for(int c=0; c<pinCount; c++){
                pinList[c].text = (char*)[constAnimTextList[c] cStringUsingEncoding:NSUTF8StringEncoding];
                
                //NSLog(@"name: %s willRendered %d\n",pinList[c].text,pinList[c].willBeRendered);
            }
            //NSLog(@"\n");
            templateApp.SetPinDatas(pinList, pinCount, 1);
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
    
}

-(void)animateTexts {
    for(int c=0; c<constPinIsAnimated.count; c++){
        if([constPinIsAnimated[c] boolValue]){
            NSInteger aState = [constAnimStates[c] integerValue];
            NSRange animSubString = NSMakeRange(aState, 25);
            NSString *whole = [NSString stringWithFormat:@"%@   %@",constTextList[c],constTextList[c]];
            [constAnimTextList replaceObjectAtIndex:c withObject:[whole substringWithRange:animSubString]];

            NSNumber *nextAstate = [NSNumber numberWithInteger: [constAnimStates[c] integerValue]+1];
            [constAnimStates replaceObjectAtIndex:c withObject:nextAstate];
            if([constAnimStates[c] integerValue] > [constTextList[c] length]+2){
                nextAstate = [NSNumber numberWithInteger:0];
                [constAnimStates replaceObjectAtIndex:c withObject:nextAstate];
            }
        }
    }
    
}

//Location Manager delegates


- (void)startCaptureLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    self.locationManager.headingFilter = kCLHeadingFilterNone;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
}

- (void)stopCaptureLocation
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopUpdatingHeading];
    self.locationManager = nil;
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
    //[self sendPinNotificationWithPinName:@"pinname" :@"description"];
    NSLog(@"curloc: %f , %f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude);
    CLLocationDistance lDistance = [newLocation distanceFromLocation:oldLocation];
    if(!locationInited) {
        locationInited = true;
        curLat = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.latitude];
        curLng = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.longitude];
        [self updatePins];
        initYaw = degToRad(heading);
    }
    if(locationInited && lDistance > 10.0f) {
        updateHeadingStored = false;
        curLat = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.latitude];
        curLng = [NSString stringWithFormat:@"%.8f",newLocation.coordinate.longitude];
        initYaw = degToRad(heading);
        //[self updatePinPositions];
    }
}


bool startHeadingStored=false, updateHeadingStored = false;
- (void) locationManager:(CLLocationManager *)manager
        didUpdateHeading:(CLHeading *)newHeading {
    heading = newHeading.trueHeading; //in degrees
    if(!startHeadingStored) {
        startingHeading = newHeading.trueHeading;
        startHeadingStored = true;
    }
    if(!updateHeadingStored) {
        updatingHeading = newHeading.trueHeading;
    }
}


//-(void)outputGyroData:(CMGyroData*) gyro {
//
//}
//
//-(void)outputAccelerationData:(CMAccelerometerData*) acceleration {
//
//}

-(void)outputMotionData:(CMDeviceMotion*) motion {
    CMQuaternion q = motion.attitude.quaternion;
    
    SCNQuaternion tmp = [self orientationFromCMQuaternion:q];

    deviceQuat.x = tmp.x;
    deviceQuat.y = tmp.y;
    deviceQuat.z = tmp.z;
    deviceQuat.w = tmp.w;
}

- (SCNQuaternion)orientationFromCMQuaternion:(CMQuaternion)q
{
    GLKQuaternion gq1 =  GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(-90), 1, 0, 0); // add a rotation of the pitch 90 degrees
    //GLKQuaternion gq3 =  GLKQuaternionMakeWithAngleAndAxis(GLKMathDegreesToRadians(0), 0, 1, 0); // add a rotation of the yaw
    GLKQuaternion gq2 =  GLKQuaternionMake(q.x, q.y, q.z, q.w); // the current orientation
    GLKQuaternion qp  =  GLKQuaternionMultiply(gq1, gq2); // get the "new" orientation
    //qp = GLKQuaternionMultiply(gq3, qp);
    CMQuaternion rq =   {.x = qp.q[0], .y = qp.q[1], .z = qp.q[2], .w = qp.q[3]};
    
    return SCNVector4Make(-rq.x, -rq.y, rq.z, rq.w);
}

#pragma mark UpdatePins
-(void) updatePins {
    pInited = false;
    //Reset arrays
    [constTextList removeAllObjects];
    [constDistanceList removeAllObjects];
    [constDescrpList removeAllObjects];
    [constPinLatList removeAllObjects];
    [constPinLngList removeAllObjects];
    [constPinImageList removeAllObjects];
    [constPinGalleryImages removeAllObjects];
    [constAnimTextList removeAllObjects];
    [constAnimStates removeAllObjects];
    [constPinOriginY removeAllObjects];
    [constPinIsAnimated removeAllObjects];
    [constGlobalBearingOffsets removeAllObjects];
    [constPinTypes removeAllObjects];
    pinCount = 0;
    pinList = NULL;
    NSString *generatedURL = [NSString stringWithFormat:@"http://app.balikesirikesfet.com/json_distance?lat=%@&lng=%@&dis=2",curLat,curLng];
    NSLog(@"generated: %@",generatedURL);
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:generatedURL]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          NSString* newStr = [[NSString alloc] initWithData:data
                                                                                   encoding:NSUTF8StringEncoding];
                                          
                                          //delete html parts if exists
                                          NSArray * components = [newStr componentsSeparatedByString:@"<br />"];
                                          newStr = (NSString *)[components objectAtIndex:0];
                                          //NSLog(@"json part: %@",newStr);
                                          
                                          // do something with the data
                                          NSData *jsonData = [newStr dataUsingEncoding:NSUTF8StringEncoding];
                                          NSError *jsError;
                                          id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsError];
                                          if (error) {
                                              //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                          }
                                          else
                                          {
                                              //Re-init pins
                                              if ([jsonObj isKindOfClass:[NSArray class]])
                                              {
                                                  //NSLog(@"it is an array!");
                                                  NSArray *jsonArray = (NSArray *)jsonObj;
                                                  
                                                  if(jsonArray.count<=0){
                                                      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"UYARI" message:@"Bulunduğunuz noktanın yakınlarında herhangi bir yer bildirimi bulunmamaktadır!" preferredStyle:UIAlertControllerStyleAlert];

                                                      UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Tamam" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                                                           {
                                                                               UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                               UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"anaSayfaVC"];
                                                                               //map2d *vc = [sb instantiateViewControllerWithIdentifier:@"haritaVC"];
                                                                               [self.navigationController pushViewController:vc animated:true];
                                                                           }];
                                                      [alert addAction:ok];
                                                      [self presentViewController:alert animated:YES completion:nil];
                                                  }

                                                  if(jsonArray.count>0 && glInitialized) {
                                                      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                      
                                                      NSLog(@"\n\nselected %ld\n\n",(long)[defaults integerForKey:@"pinCategorySelection"]);
                                                      
                                                      pinCount = (int)jsonArray.count;
                                                      pinList = NULL;
                                                      pinList = (pinData*)malloc(sizeof(pinData)*(int)jsonArray.count);

                                                      float closestDist  = 0.01f; //CLosest const
                                                      float furthestDist = 2.0f; //Furthest const
                                                      float k10 = 0.7f;
                                                      float k25 = 0.33f;
                                                      float start = -0.12f;
                                                      float end = 0.17f;
                                                      
                                                      startingHeading = heading;
                                                      
                                                      
                                                      for(int cnt=0; cnt<jsonArray.count; cnt++){
                                                          
                                                          float pLat = [(jsonArray[cnt][@"lat"]) floatValue];
                                                          float pLng = [(jsonArray[cnt][@"lng"]) floatValue];
                                                          CLLocation* tmpPinLoc = [[CLLocation alloc] initWithLatitude:pLat longitude:pLng];
                                                          
                                                          if([currentLocation distanceFromLocation:tmpPinLoc]/1000.0f<0.01f || [defaults integerForKey:@"pinCategorySelection"] != [(jsonArray[cnt][@"type"]) integerValue] ) {
                                                              //NSLog(@"skipped: %@ \n",jsonArray[cnt][@"title"]);
                                                              pinList[cnt].willBeRendered = false;
                                                              //continue;
                                                          } else {
                                                              pinList[cnt].willBeRendered = true;
                                                          }
                                                          
                                                          
                                                          [constPinLatList addObject:jsonArray[cnt][@"lat"]];
                                                          [constPinLngList addObject:jsonArray[cnt][@"lng"]];
                                                          [constPinTypes addObject:jsonArray[cnt][@"type"]];
                                                          
#pragma mark Calculate Bearing and set pin positions
                                                          double bearing = [self getBearing:currentLocation.coordinate.latitude :currentLocation.coordinate.longitude :tmpPinLoc.coordinate.latitude :tmpPinLoc.coordinate.longitude];
                                                          float dist = [currentLocation distanceFromLocation:tmpPinLoc]/1000.0f;
                                                        
                                                          float projecDist = [self mapNumber:closestDist :furthestDist :0.4f :0.8f :dist];
                                                          double bearingOffset = 0.0f;
                                                          
                                                          [self getBearingOffset:bearing bearingOffset:bearingOffset];

                                                          pLat = cos(degToRad(bearingOffset)) * projecDist;
                                                          pLng = sin(degToRad(bearingOffset)) * projecDist;
                                                          float altitude = [self mapNumber:closestDist :furthestDist :start :end :dist];
                                                          
                                                          [constTextList addObject:jsonArray[cnt][@"title"]];
                                                          [constAnimTextList addObject:[NSString stringWithFormat:@"%@",jsonArray[cnt][@"title"]]];
                                                          
                                                          NSString* tmpDesc = jsonArray[cnt][@"description"];
                                                          if(tmpDesc == [NSNull null]) {
                                                              tmpDesc = @" ";
                                                          }
                                                          
                                                          NSInteger defs = [defaults integerForKey:@"pinCategorySelection"];
                                                          NSString* tmpDate1 = [NSString stringWithFormat:@"%@ - %@\n",jsonArray[cnt][@"date1"],jsonArray[cnt][@"time1"]];
                                                          if(tmpDate1 == [NSNull null]) {
                                                              tmpDate1 = @" ";
                                                          }
                                                          NSString* tmpDate2 = [NSString stringWithFormat:@"%@ - %@\n",jsonArray[cnt][@"date2"],jsonArray[cnt][@"time2"]];
                                                          if(tmpDate2 == [NSNull null]) {
                                                              tmpDate2 = @" ";
                                                          }
                                                          if([(jsonArray[cnt][@"type"]) integerValue] == 1){
                                                              
                                                              NSString *tmpdsc1 = [NSString stringWithFormat:@"%@\nEtkinlik Başlama Tarihi: %@\nBitiş Tarihi: %@",tmpDesc,tmpDate1,tmpDate2];
                                                              [constDescrpList addObject:tmpdsc1];
                                                              NSLog(@"%@ : desc1: %@",jsonArray[cnt][@"title"],tmpdsc1);
                                                          } else {
                                                              [constDescrpList addObject:tmpDesc];
                                                              NSLog(@"%@ : descNOT1: %@",jsonArray[cnt][@"title"],tmpDesc);
                                                          }
                                                          
                                                          
//                                                          float dist = [currentLocation distanceFromLocation:tmpPinLoc];
                                                          [constDistanceList addObject:[NSString stringWithFormat:@"%.2f KM",dist]];
    
                                                          //Set offset and animstates depending on the title
                                                          if([constTextList[cnt] length] <= 10)
                                                          {
                                                              NSNumber *isAnimated = [NSNumber numberWithBool:false];
                                                              NSNumber *animState  = [NSNumber numberWithInteger:0];
                                                              [constPinIsAnimated addObject:isAnimated];
                                                              [constAnimStates addObject:animState];
                                                              pinList[cnt].fontSize = k10;
                                                              pinList[cnt].originY= 0.0f;
                                                          }
                                                          else if ([constTextList[cnt] length]  <= 25)
                                                          {
                                                              NSNumber *isAnimated = [NSNumber numberWithBool:false];
                                                              [constPinIsAnimated addObject:isAnimated];
                                                              NSNumber *animState  = [NSNumber numberWithInteger:0];
                                                              [constAnimStates addObject:animState];
                                                              pinList[cnt].fontSize = [self mapNumber:10.0f :25.0f :k10*0.8f :k25 :[constTextList[cnt] length]];
                                                              pinList[cnt].originY = [self mapNumber:10.0f :25.0f :0.0f :0.005f :[constTextList[cnt] length]];
                                                          }
                                                          else
                                                          {
                                                              pinList[cnt].originY= 0.005f;
                                                              pinList[cnt].fontSize = k25;
                                                              NSNumber *isAnimated = [NSNumber numberWithBool:true];
                                                              [constPinIsAnimated addObject:isAnimated];
                                                              NSNumber *animState  = [NSNumber numberWithInteger:0];
                                                              [constAnimStates addObject:animState];
                                                          }
                                                          
                                                          pinList[cnt].id = cnt;
                                                          pinList[cnt].position = {pLat, altitude, pLng};
                                                          pinList[cnt].text = (char*)[constTextList[cnt] cStringUsingEncoding:NSUTF8StringEncoding];
                                                          pinList[cnt].size = 0.04f;
                                                          //pinList[cnt].originY = 0.0f;
                                                          //pinList[cnt].fontSize = 0.65f;
                                                          pinList[cnt].color = {1.0f, 1.0f, 1.0f, 1.0f};
                                                          pinList[cnt].borderColor = {0.14f, 0.30f, 0.43f, 1.0f};
                                                          
                                                          //Add images to gallery array
                                                          NSMutableArray* imgGalJson    = [[jsonArray[cnt][@"pic2"] allObjects] mutableCopy];
                                                          [imgGalJson removeObject:@""];
                                                          if(imgGalJson.count > 0){
                                                              [constPinImageList addObject:imgGalJson];
                                                          } else {
                                                              constPinImageList[cnt] = [[NSMutableArray alloc] init];
                                                          }
                                                          
                                                          if(cnt==0) {
                                                              //NSLog(@"init name: %@ bearingOff: %f , projectDist: %f , tmpPinLoc: %f",constTextList[cnt],bearingOffset,projecDist, tmpPinLoc.coordinate.latitude);
                                                          }
                                                      }
                                                          LOGI("\n\n");
                                                          templateApp.SetPinDatas(pinList,pinCount,1.0f);
                                                          pInited = true;
                                                      
                                                  } else {
                                                      pinCount = 0;
                                                  }
                                              }
                                              else {
                                                  NSLog(@"it is a dictionary");
                                                  NSDictionary *jsonDictionary = (NSDictionary *)jsonObj;
                                                  NSLog(@"jsonDictionary - %@",jsonDictionary);
                                              }
                                          }
                                      }];
    [dataTask resume];
}

- (void)getBearingOffset:(double)bearing bearingOffset:(double &)bearingOffset {
    bearingOffset = (startingHeading-bearing) + 90.0f ;
    if(bearingOffset<0.0f){
        bearingOffset = 360.0f + bearingOffset;
    }
    if(bearingOffset>360.0f){
        bearingOffset = bearingOffset-360.0f;
    }
}

-(void) updatePinPositions {
    if(pInited && pinCount>0) {
        float closestDist  = 0.01f;
        float furthestDist = 2.0f;
        float start = -0.12f;
        float end = 0.17f;

        double bearingOffset = 0.0f;
        for(int i=0;i<pinCount;i++) {
            float pLat = [constPinLatList[i] floatValue]; float pLng = [constPinLngList[i] floatValue];
            CLLocation* tmpPinLoc = [[CLLocation alloc] initWithLatitude:pLat longitude:pLng];
            
            double bearing = [self getBearing:currentLocation.coordinate.latitude :currentLocation.coordinate.longitude :tmpPinLoc.coordinate.latitude :tmpPinLoc.coordinate.longitude];
            float dist = [currentLocation distanceFromLocation:tmpPinLoc]/1000.0f;
            
            constDistanceList[i] = [NSString stringWithFormat:@"%.2f KM",dist];
            float projecDist = [self mapNumber:closestDist :furthestDist :0.4f :0.8f :dist];
            [self getBearingOffset:bearing bearingOffset:bearingOffset];

            pLat = cos(degToRad(bearingOffset)) * projecDist;
            pLng = sin(degToRad(bearingOffset)) * projecDist;
            
            float altitude = [self mapNumber:closestDist :furthestDist :start :end :dist];
            pinList[i].position = {pLat, altitude, pLng};
            
        }
        updateHeadingStored = true;
    }
}



-(double)getBearing:(double)lt1:(double)lg1:(double)lt2:(double)lg2 {
    double dLon = (lg2-lg1);
    double y = sin(degToRad(dLon)) * cos(degToRad(lt2));
    double x = cos(degToRad(lt1))*sin(degToRad(lt2)) - sin(degToRad(lt1))*cos(degToRad(lt2))*cos(degToRad(dLon));
    double brng = radToDeg((atan2(y, x)));
    return brng;
    //return (360 - ((brng + 360) % 360));
}

-(float)mapNumber:(float)a1:(float)a2:(float)b1:(float)b2:(float)x {
    return (x-a1) / (a2-a1) * (b2 - b1) + b1;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    if(!annotationOpened){
        if(selectedPinId > -1){
            storedPinId = selectedPinId;
            if([constPinImageList[storedPinId] count]<1){
                self.galleryColView.alpha = 0.0f;
            } else {
                self.galleryColView.alpha = 1.0f;
            }
            [self.pinTitle setText:constTextList[storedPinId]];
            [self.pinInfo setText:constDescrpList[storedPinId]];
            [self annotationIn];
        }
    }
    
}

-(void) sendPinNotificationWithPinName: (NSString*) name: (NSString*) description {
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Yeni Pin Alındı";
    content.body = [NSString stringWithFormat:@"%@ %@",name,description];
    content.sound = [UNNotificationSound defaultSound];
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    UNNotificationRequest *notifRequest = [UNNotificationRequest requestWithIdentifier:@"Pin Notif" content:content trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:notifRequest withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"add NotificationRequest succeeded!");
        }
    }];
}

-(void) startCameraPreview {
    //-- Create CVOpenGLESTextureCacheRef for optimal CVImageBufferRef to GLES texture conversion.
#if COREVIDEO_USE_EAGLCONTEXT_CLASS_IN_API
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
#else
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)_context, NULL, &_videoTextureCache);
#endif
    if (err)
    {
        NSLog(@"1-Error at CVOpenGLESTextureCacheCreate %d", err);
        return;
    }
    //Video Device
    captureSession = [AVCaptureSession new];
    captureSession = [[AVCaptureSession alloc] init];
    [captureSession beginConfiguration];
    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if(videoDevice == nil) {
        assert(0);
        NSLog(@"video device error...");
    }
    
    
    //Add device to session
    NSError* error;
    AVCaptureInput* input = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error: &error];
    if(error) {
        assert(0);
        NSLog(@"video device session error...");
    }
    [captureSession addInput:input];
    //preview layer

    //-- Create the output for the capture session.
    AVCaptureVideoDataOutput * dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording

    //-- Set to YUV420.
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey]]; // Necessary for manual preview

    // Set dispatch to be on the main thread so OpenGL can do things with the data
    [dataOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    [captureSession addOutput:dataOutput];
    [captureSession commitConfiguration];
    
    [captureSession startRunning];

}
bool camSizeSet = false;
//AV Outputdelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    GLsizei width = (GLsizei)CVPixelBufferGetWidth(pixelBuffer);
    GLsizei height = (GLsizei)CVPixelBufferGetHeight(pixelBuffer);

    
    if (!_videoTextureCache)
    {
        NSLog(@"No video texture cache");
        return;
    }
    
    //[self cleanUpTextures];
    if(camTextureRefY){
        CFRelease(camTextureRefY);
    }
    if(camTextureRefUV){
        CFRelease(camTextureRefUV);
    }
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
    
    // CVOpenGLESTextureCacheCreateTextureFromImage will create GLES texture
    // optimally from CVImageBufferRef.
    
    // Y-plane
    glActiveTexture(GL_TEXTURE0);
    CVReturn err;
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_LUMINANCE,
                                                       width,
                                                       height,
                                                       GL_LUMINANCE,
                                                       GL_UNSIGNED_BYTE,
                                                       0,
                                                       &camTextureRefY);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    GLuint textureId =CVOpenGLESTextureGetName(camTextureRefY);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // UV-plane
    glActiveTexture(GL_TEXTURE1);
    err = 0;
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                       _videoTextureCache,
                                                       pixelBuffer,
                                                       NULL,
                                                       GL_TEXTURE_2D,
                                                       GL_RG_EXT,
                                                       width/2,
                                                       height/2,
                                                       GL_RG_EXT,
                                                       GL_UNSIGNED_BYTE,
                                                       1,
                                                       &camTextureRefUV);
    if (err)
    {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    }
    GLuint textureIdUV =CVOpenGLESTextureGetName(camTextureRefUV);
    glBindTexture(GL_TEXTURE_2D, textureIdUV);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    templateApp.BindCameraTexture(textureId,textureIdUV);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(pinInfoViewOpened)
        [self pinInfoViewOut];
    if(annotationOpened)
        [self annotationOut];
    glInitialized = false; drawApp = false;
    [self.motionManager stopDeviceMotionUpdates];
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopMagnetometerUpdates];
    [self.motionManager stopAccelerometerUpdates];
    [self stopCaptureLocation];

    templateApp.Exit();
    //Dealloc
    drawApp = false;
    pinList = NULL;
    free(pinList);
    pinCount = 0;
    
    [constTextList removeAllObjects];
    [constDistanceList removeAllObjects];
    [constDescrpList removeAllObjects];
    [constPinLatList removeAllObjects];
    [constPinLngList removeAllObjects];
    [constPinImageList removeAllObjects];
    [constPinGalleryImages removeAllObjects];
    [constAnimTextList removeAllObjects];
    [constAnimStates removeAllObjects];
    [constPinOriginY removeAllObjects];
    [constPinIsAnimated removeAllObjects];
    [constGlobalBearingOffsets removeAllObjects];
    [constPinTypes removeAllObjects];
}

#pragma mark SWRevealControllerDelegate
- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position {
    long tagId = 4207868622;
    if(position == FrontViewPositionLeft) {
        UIView* lock = [self.view viewWithTag:tagId];
        [lock setAlpha:0.333];
        [UIView animateWithDuration:0.5 animations:^{
            lock.alpha = 0.0;
        } completion:^(BOOL finished) {
            [lock removeFromSuperview];
        }];
    }
    if(position == FrontViewPositionRight) {
        UIView* lock = [[UIView alloc] initWithFrame:self.view.bounds];
        lock.tag = tagId;
        lock.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
        [lock setAlpha:0.333];
        [lock setBackgroundColor:[UIColor blackColor]];
        [UIView animateWithDuration:0.5 animations:^{
            lock.alpha = 0.333;
        }];
    }
}

#pragma mark POPUPS
-(void)controlPopupVisibility {
    if(selectedPinId==-1 && pinInfoViewOpened)
        [self pinInfoViewOut];
}

-(void) pinInfoViewIn{
    if(!annotationOpened) {
        pinInfoViewOpened = true;
        [self.view addSubview:self.pinInfoView];
        [self.pinInfoView setCenter:CGPointMake(self.view.center.x, self.view.bounds.size.height-self.pinInfoView.bounds.size.height)];
        self.pinInfoView.alpha = 0.0f;
        
        [UIView animateWithDuration:0.4f animations:^{
            self.pinInfoView.alpha = 1.0f;
        }];
    }
}
-(void) pinInfoViewOut{
    //self.pinInfo.text = @" ";
    self.pinInfoView.alpha = 1.0f;
    [UIView animateWithDuration:0.3f animations:^{
        self.pinInfoView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.pinInfoView removeFromSuperview];
        pinInfoViewOpened = false;
    }];
}
-(void) annotationIn{
    [self pinInfoViewOut];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.galleryColView reloadData];
    });
    annotationOpened = true;
    [self.view addSubview:self.annotationPopup];
    [self.annotationPopup setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    self.annotationPopup.alpha = 0.0f;
    
    [UIView animateWithDuration:0.4f animations:^{
        self.annotationPopup.alpha = 1.0f;
    }];
}
-(void) annotationOut{
    
    self.annotationPopup.alpha = 1.0f;
    [UIView animateWithDuration:0.3f animations:^{
        self.annotationPopup.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.annotationPopup removeFromSuperview];
        annotationOpened = false;
        self.pinInfo.text = @" ";
    }];
}


#pragma mark PinInfoView
int storedPinId=-1;
- (IBAction)openAnnotation:(id)sender {
    if(selectedPinId > -1){
        storedPinId = selectedPinId;
        if([constPinImageList[storedPinId] count]<1){
            self.galleryColView.alpha = 0.0f;
        } else {
            self.galleryColView.alpha = 1.0f;
        }
        [self.pinTitle setText:constTextList[storedPinId]];
        NSLog(@"\n\ndescList: %@\n\n",constDescrpList[storedPinId]);
        [self.pinInfo setText:constDescrpList[storedPinId]];
        [self annotationIn];
    }
}

- (IBAction)closeAnnotation:(id)sender {
    storedPinId = -1;
    //[self.pinInfo setText:@" "];
    [self annotationOut];
}

#pragma mark ShowOnMap
- (IBAction)showOnMap:(id)sender {
    annotationOpened = false;
    NSInteger myObjcData = (NSInteger)storedPinId;
    storedPinId = -1;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:myObjcData forKey:@"mapSelectedPinId"];
    [defaults synchronize];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"haritaVC"];
    //map2d *vc = [sb instantiateViewControllerWithIdentifier:@"haritaVC"];
    [self.navigationController pushViewController:vc animated:true];
}
#pragma mark CollectionView for gallery
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(pinCount > 0 && storedPinId > -1){
        return [constPinImageList[storedPinId] count];
    } else {
        return 0;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    objcPinPicCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"objcPinPicCell" forIndexPath:indexPath];
    if([constPinImageList[storedPinId] count] > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* imageUrl = [NSString stringWithFormat:@"http://app.balikesirikesfet.com/%@",constPinImageList[storedPinId][indexPath.item]];
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageUrl]];
            cell.detailPic.image = [UIImage imageWithData:imageData];
        });
        }
    return cell;
}

#pragma mark AlertView

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

