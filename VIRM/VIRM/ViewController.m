//
//  ViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    iqengines = [[IQE alloc] initWithSearchType:IQESearchTypeRemoteSearch apiKey:@"5de79cc588d5435d8ad3c6a13bf711d5" apiSecret:@"de9d9ac4582d412a96624b1d03b87a84"];
    
    iqengines.delegate = self;

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = self.view.layer.bounds;
    iqengines.previewLayer.bounds = rect;
    iqengines.previewLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    [self.view.layer insertSublayer:iqengines.previewLayer atIndex:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [iqengines startCamera];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    [iqengines stopCamera];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) dealloc {
    iqengines.delegate = nil;
    [iqengines stopCamera];
}
- (IBAction)cameraClicked:(id)sender {
    [iqengines captureStillFrame];
}

-(void)iqEngines:(IQE *)iqe didCaptureStillFrame:(UIImage *)image {
    printf("Frame captured!\n");
    NSString* qid = [iqengines searchWithImage:image];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
 
    printf("QID: %s\n", [qid UTF8String]);
    
    [iqengines updateResults:dict forQID:qid];
    printf("Updated results!");
    
    //[iqengines searchWithQID:qid];
}

- (void)updateCompleteWithResults:(NSArray*)results
{
    printf("updateCompleteWithResults called! :)");
}

- (void)iqEngines:(IQE *)iqe failedWithError:(NSError *)error {
    printf("failedWithError called! :(");
}
@end
