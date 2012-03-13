//
//  FirstViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "AppDelegate.h"

@implementation CameraViewController

@synthesize imagePicker = _imagePicker;
@synthesize image = _image;
@synthesize imageView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.delegate = (id)self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    imageView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)cameraClicked:(id)sender {    
    printf("[CameraVC] Camera clicked.\n");
    
	_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
	[self presentModalViewController:_imagePicker animated:YES];	
}

- (IBAction)libraryClicked:(id)sender {
    printf("[CameraVC] Library clicked.\n");
    
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:_imagePicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    printf("[CameraVC] Image picked.\n");
    
    _image = img;
    [_imagePicker dismissModalViewControllerAnimated:YES];
    imageView.image = _image;

    
    
    
//    // This implementation is bad and unfinished, its just here for testing purposes!
//    
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	imageView = [[UIImageView alloc] initWithFrame:[appDelegate.window bounds]];
//	imageView.hidden = YES;
//	[appDelegate.window addSubview:imageView];
//    
//    [appDelegate.window makeKeyAndVisible];
//    
//	// Dismiss the image selection, hide the picker and show the image view with the picked image
//	[picker dismissModalViewControllerAnimated:YES];
//	_imagePicker.view.hidden = YES;
//	imageView.image = img;
//	imageView.hidden = NO;
//
//	[appDelegate.window bringSubviewToFront:imageView];
//    printf("[CameraVC] Image picked.\n");
}
@end
