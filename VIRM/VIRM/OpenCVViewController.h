//
//  OpenCVViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenCVViewController : UIViewController
{
    cv::VideoCapture *_videoCapture;
    cv::Mat _lastFrame;
    NSTimer *timer;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSTimer *timer;

@end
