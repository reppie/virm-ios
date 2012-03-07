//
//  ViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@implementation ViewController

@synthesize imagePicker = _imagePicker;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
//    iqengines = [[IQE alloc] initWithSearchType:IQESearchTypeRemoteSearch apiKey:@"5de79cc588d5435d8ad3c6a13bf711d5" apiSecret:@"de9d9ac4582d412a96624b1d03b87a84"];
//    
//    iqengines.delegate = self;
//
    [super viewDidLoad];
//	// Do any additional setup after loading the view, typically from a nib.
//    
//    CGRect rect = self.view.layer.bounds;
//    iqengines.previewLayer.bounds = rect;
//    iqengines.previewLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
//    
//    [self.view.layer insertSublayer:iqengines.previewLayer atIndex:0];
    
    _imagePicker = [[UIImagePickerController alloc] init];
    
    // Set up the image view and add it to the view but make it hidden
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	imageView = [[UIImageView alloc] initWithFrame:[appDelegate.window bounds]];
	imageView.hidden = YES;
	[appDelegate.window addSubview:imageView];
    
    [appDelegate.window makeKeyAndVisible];
    
    _imagePicker.delegate = (id)self;
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
    
//    [iqengines startCamera];
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
//    [iqengines stopCamera];
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
    // Set source to the camera
	_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    // Show image picker
	[self presentModalViewController:_imagePicker animated:YES];	
}

- (IBAction)libraryClicked:(id)sender {
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:_imagePicker animated:YES];	
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	// Dismiss the image selection, hide the picker and show the image view with the picked image
	[picker dismissModalViewControllerAnimated:YES];
	_imagePicker.view.hidden = YES;
	imageView.image = img;
	imageView.hidden = NO;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate.window bringSubviewToFront:imageView];
}
@end
