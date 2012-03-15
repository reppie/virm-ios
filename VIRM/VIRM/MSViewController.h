/**
 * Copyright (c) 2012 Moodstocks SAS
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

#if !TARGET_IPHONE_SIMULATOR
#define MS_HAS_AVFF 1
#endif

#if MS_HAS_AVFF
#import <AVFoundation/AVFoundation.h>
#endif

#import "MSScanner.h"

@protocol MSScannerOverlayDelegate;
@class MSViewController;

@interface MSViewController : UIViewController
#if MS_HAS_AVFF
<MSScannerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate
>
#endif
{
    UIView* _videoPreviewView;
#if MS_HAS_AVFF
    AVCaptureSession*           captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoOrientation   orientation;
    dispatch_queue_t            videoDataOutputQueue;
#endif
    BOOL _processFrames;      // frames processing enabled / disabled
    NSString *_result;        // previous result
    MSResultType _resultType; // previous result type
    NSInteger _losts;         // previous result "lock lost" counter
    NSTimeInterval _ts;       // timestamp of the latest result found
    
    BOOL recognized;          // check for first image recognized
}

@property (nonatomic, retain) UIView *videoPreviewView;
#if MS_HAS_AVFF
@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) AVCaptureVideoOrientation orientation;
#endif

@end

