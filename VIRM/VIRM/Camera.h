//
//  Camera.h
//  VIRM
//
//  Created by Clockwork Clockwork on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Camera : NSObject

- (id)initWithViewController: (UIViewController *) viewController;
- (void)stop;
- (void)start;
- (void)setup;
- (AVCaptureVideoDataOutput *) getOutput;
- (AVCaptureSession *) getCaptureSession;

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) UIViewController *viewController;
@property (nonatomic, retain) AVCaptureVideoDataOutput *output;

@end
