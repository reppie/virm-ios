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

using namespace std;
using namespace cv;

@interface OpenCVViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, NSStreamDelegate> {

    NSInputStream *iStream;
    NSOutputStream *oStream;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    NSMutableData *eventQueue;
    Byte event[1];
    int counter;    
    
	AVCaptureSession *_captureSession;
	AVCaptureVideoPreviewLayer *_prevLayer;
    
    AppDelegate *appDelegate;
    MBProgressHUD *HUD;   
    BOOL finishedLaunching;
    
    Recognizer *recognizer;
    Utils *utils;
    
    vector<NSString*> fileNames;
    vector<Mat> dataSetDescriptors;    
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@end
