//
//  Recognizer.h
//  VIRM
//
//  Created by Clockwork Clockwork on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

using namespace std;
using namespace cv;

@interface Recognizer : NSObject {
    vector<Mat> dataSetDescriptors;
    vector<KeyPoint> keypoints;
    vector<DMatch> matches;
    
    Mat capturedDescriptors;    
    Mat matchImage;
    Mat grayImage;
    
    OrbFeatureDetector featureDetector;
    OrbDescriptorExtractor featureExtractor;   
    
    AppDelegate *appDelegate;
    int imageId;
}

- (id) initWithDataSet: (vector<Mat>) dataset;
- (Mat) getTestMat;
- (int) recognize: (UIImage *) image;
- (Mat) getDescriptors: (UIImage *) image;
- (int) match: (Mat) capturedMat;

@end
