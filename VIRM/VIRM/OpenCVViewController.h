//
//  OpenCVViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Recognizer.h"
#import "Utils.h"
#import "Camera.h"
#import "NetworkHandler.h"

using namespace std;
using namespace cv;

@interface OpenCVViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {    
    
    AppDelegate *appDelegate;
    MBProgressHUD *HUD;   
    BOOL finishedLaunching;
    
    Recognizer *recognizer;
    Utils *utils;
    Camera *camera;    
    NetworkHandler *networkHandler;
    
    vector<NSString*> fileNames;
    vector<Mat> dataSetDescriptors;    
}

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@end
