//
//  agGL.h
//  balikesiriKesfet
//
//  Created by xloop on 26/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreLocation/CoreLocation.h>
//#import "balikesiriKesfet-Swift.h"
#import "CaptureSessionManager.h"
#import "App.h"
#import "EngineBase.h"
#import "Logger.h"

@interface agGL : GLKViewController <CLLocationManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    
}
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *openMenuBut;
@property (weak, nonatomic) IBOutlet UILabel *pinTitle;
@property (weak, nonatomic) IBOutlet UICollectionView *galleryColView;
@property (weak, nonatomic) IBOutlet UILabel *pinInfo;
@property (strong, nonatomic) IBOutlet UIView *annotationPopup;
@property (weak, nonatomic) IBOutlet UIButton *annotationExitBut;
@property (strong, nonatomic) IBOutlet UIView *pinInfoView;
@property (weak, nonatomic) IBOutlet UIView *pinInfoBg;
@property (weak, nonatomic) IBOutlet UIButton *pinInfoDetailBut;
@property (weak, nonatomic) IBOutlet UILabel *pinInfoDistance;
@property (weak, nonatomic) IBOutlet UILabel *pinInfoTitle;
@property (weak, nonatomic) IBOutlet UIImageView *crosshairImag;
- (IBAction)openAnnotation:(id)sender;
- (IBAction)closeAnnotation:(id)sender;

- (void)startCaptureLocation;
- (void)stopCaptureLocation;

@end

