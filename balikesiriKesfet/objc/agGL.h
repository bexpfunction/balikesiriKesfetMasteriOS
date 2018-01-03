//
//  agGL.h
//  balikesiriKesfet
//
//  Created by xloop on 26/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
#import "CaptureSessionManager.h"

UILabel *infoLabel;
struct miniGLMembers;

@interface agGL : GLKViewController{
    struct miniGLMembers *_miniGLMembers;
}
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)startCaptureLocation;
- (void)stopCaptureLocation;

@end

