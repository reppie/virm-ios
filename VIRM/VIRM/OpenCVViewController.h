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

using namespace std;
using namespace cv;

@interface OpenCVViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession *_captureSession;
	AVCaptureVideoPreviewLayer *_prevLayer;
    
    OrbFeatureDetector featureDetector;
    OrbDescriptorExtractor featureExtractor;
    
    vector<KeyPoint> testKeypoints;    
    vector<KeyPoint> keypointsCapture;
    vector<DMatch> matches;
    int goodMatches;
    
    Mat descriptorsCapture;
    Mat testDescriptors;
    
    vector<Mat> dataSetDescriptors;
    vector<NSString*> fileNames;
    
    AppDelegate *appDelegate;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@end
