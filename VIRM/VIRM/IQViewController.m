//
//  IQViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IQViewController.h"

@interface IQViewController ()

@end

@implementation IQViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    printf("[IQ Engines] View loaded.\n");
    
    printf("[IQ Engines] Initializing.\n");
    iqengines = [[IQE alloc] initWithSearchType:IQESearchTypeAll apiKey:@"5de79cc588d5435d8ad3c6a13bf711d5" apiSecret:@"de9d9ac4582d412a96624b1d03b87a84"];
    iqengines.delegate = self;
    
    CGRect rect = self.view.layer.bounds;
    iqengines.previewLayer.bounds = rect;
    iqengines.previewLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    [self.view.layer insertSublayer:iqengines.previewLayer atIndex:0];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [iqengines startCamera];    
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    
    [iqengines stopCamera];
}

- (IBAction) onCameraButton: (id) sender {
    [iqengines captureStillFrame];
}

- (void) iqEngines:(IQE *)iqe didCaptureStillFrame:(UIImage *)image {
    NSString* qid = [iqengines searchWithImage: image];
    printf("[IQ Engines] QID: %s", [qid UTF8String]);
}

- (void) iqEngines:(IQE *)iqe didCompleteSearch:(IQESearchType)type withResults:(NSDictionary *)results forQID:(NSString *)qid {
    NSLog(@"results:%@", results);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
