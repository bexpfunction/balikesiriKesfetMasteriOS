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

@interface agGL : GLKViewController <CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    struct objCPinData{
    public:
        int id;
        vec3 position;
        char *text;
        vec4 color;
        vec4 borderColor;
    };
    
}
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openMenuBut;

- (void)startCaptureLocation;
- (void)stopCaptureLocation;

@end

