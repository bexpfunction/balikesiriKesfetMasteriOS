//
//  agGL.h
//  balikesiriKesfet
//
//  Created by xloop on 26/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "CaptureSessionManager.h"
#import "App.h"
#import "EngineBase.h"
#import "Logger.h"

UILabel *infoLabel;
static pinData* pinList;

@interface agGL : GLKViewController{

}
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openMenuBut;

- (void)startCaptureLocation;
- (void)stopCaptureLocation;

@end

