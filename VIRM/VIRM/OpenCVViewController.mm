//
//  OpenCVViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+OpenCV.h"

#import "OpenCVViewController.h"

// Aperture value to use for the Canny edge detection
const int kCannyAperture = 7;

@interface OpenCVViewController ()
- (void)processFrame;
@end

@implementation OpenCVViewController

@synthesize imageView = _imageView;
@synthesize timer = _timer;

- (void)viewDidLoad
{
    printf("[OpenCV] View loaded.\n");
    [super viewDidLoad];

}


- (void)viewDidAppear:(BOOL)animated {
    printf("[OpenCV] View appeared.\n");
    _videoCapture = new cv::VideoCapture;
    
    if (!_videoCapture->open(CV_CAP_AVFOUNDATION))
    {
        printf("[OpenCV] Failed to open video camera.\n");
    }
    [self startCapture];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopCapture];
}

- (void)startCapture {
    printf("[OpenCV] Starting videocapture.\n");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(capture) userInfo:nil repeats:YES];
}

- (void) stopCapture
{
    printf("[OpenCV] Stopping videocapture.\n");
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.imageView = nil;

    delete _videoCapture;
    _videoCapture = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Grab a frame and process it
- (void)capture
{
    if (_videoCapture && _videoCapture->grab())
    {
        (*_videoCapture) >> _lastFrame;
        [self processFrame];
    }
    else
    {
        printf("[OpenCV] Failed to grab frame.\n");        
    }
}

// Perform image processing on the last captured frame and display the results
- (void)processFrame
{
    double t = (double)cv::getTickCount();
    
    cv::Mat grayFrame, output;
    
    // Convert captured frame to grayscale
    cv::cvtColor(_lastFrame, grayFrame, cv::COLOR_RGB2GRAY);
    
    // Perform Canny edge detection using slide values for thresholds
    cv::Canny(grayFrame, output,
              0.1 * kCannyAperture * kCannyAperture,
              0.1 * kCannyAperture * kCannyAperture,
              kCannyAperture);
    
    t = 1000 * ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    
    // Display result 
    self.imageView.image = [UIImage imageWithCVMat:output];
}

@end
