//
//  OpenCVViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#include <opencv2/core/core.hpp>
#include <opencv2/features2d/features2d.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <vector>

using namespace std;
using namespace cv;

@interface OpenCVViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate> {
	AVCaptureSession *_captureSession;
	AVCaptureVideoPreviewLayer *_prevLayer;
    int totalCaptures;
    int totalMatches;
    
    OrbFeatureDetector featureDetector;
    OrbDescriptorExtractor featureExtractor;
    
    vector<KeyPoint> keypointsTrained;    
    vector<KeyPoint> keypointsCapture;
    vector<DMatch> matches;
    vector<DMatch> good_matches;
    
    Mat descriptorsCapture;
    Mat descriptorsTrained;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;

@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@end
