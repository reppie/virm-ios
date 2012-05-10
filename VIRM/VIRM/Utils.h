//
//  Utils.h
//  VIRM
//
//  Created by Clockwork Clockwork on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

using namespace std;
using namespace cv;

@interface Utils : NSObject {
    NSMutableArray *imageList;   
    AppDelegate *appDelegate;  
    vector<NSString*> fileNames;
}

- (void) initializeImageList;
- (vector<Mat>) getDescriptorsFromMatFiles;
- (vector<Mat>) getDescriptorsFromImageFiles: (BOOL) saveToMat;
- (vector<NSString*>) getFileNames;
- (Mat)MatFromUIImage:(UIImage *)image;
- (IplImage *)IplImageFromUIImage:(UIImage *)image;
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;

@end
