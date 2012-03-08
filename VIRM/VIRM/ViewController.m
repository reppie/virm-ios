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
    [super viewDidLoad];
    
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

- (void) dealloc {
}
- (IBAction)cameraClicked:(id)sender {    
    // Set source to the camera
	_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
    
    // Show image picker
	[self presentModalViewController:_imagePicker animated:YES];	
}

- (IBAction)libraryClicked:(id)sender {
    printf("Library clicked!\n");
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.view.hidden = NO;
    [self presentModalViewController:_imagePicker animated:YES];	
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    printf("Touched\n");
    if (imageView.hidden == NO) {
        printf("Touched in imageView\n");
        imageView.hidden = YES;
    }
}
@end
