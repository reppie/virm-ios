//
//  ViewController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MultiViewController.h"
#import "MiscViewController.h"
#import "MainViewController.h"

@implementation MultiViewController

@synthesize imagePicker = _imagePicker;

UIViewController  *currentView;

- (void) displayView:(int)intNewView {
	printf("[MultiVC] Displaying new view: %i\n", intNewView);

    [currentView.view removeFromSuperview];
    
	switch (intNewView) {
		case 1:
            printf("[MultiVC] Initializing MainViewController\n");
			currentView = [[MainViewController alloc] init];
			break;
		case 2:
            printf("[MultiVC] Initializing MiscViewController\n");
			currentView = [[MiscViewController alloc] init];
			break;
	}
	[self.view addSubview:currentView.view];
}

- (void)viewDidLoad {
    printf("[MultiVC] View loaded.\n");
	// display Welcome screen
	currentView = [[MainViewController alloc] init];
	[self.view addSubview:currentView.view];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Release any cached data, images, etc that aren't in use.
//}
//
//#pragma mark - View lifecycle
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    _imagePicker = [[UIImagePickerController alloc] init];
//    
//    // Set up the image view and add it to the view but make it hidden
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	imageView = [[UIImageView alloc] initWithFrame:[appDelegate.window bounds]];
//	imageView.hidden = YES;
//	[appDelegate.window addSubview:imageView];
//    
//    [appDelegate.window makeKeyAndVisible];
//    
//    _imagePicker.delegate = (id)self;
//}
//
//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//	[super viewWillDisappear:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//	[super viewDidDisappear:animated];
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}
//
//- (void) dealloc {
//}
//- (IBAction)cameraClicked:(id)sender {    
//    printf("[MVC] Camera clicked!\n");
//    // Set source to the camera
//	_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
//    
//    // Show image picker
//	[self presentModalViewController:_imagePicker animated:YES];	
//}
//
//- (IBAction)libraryClicked:(id)sender {
//    printf("[MVC] Library clicked!\n");
//    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    _imagePicker.view.hidden = NO;
//    [self presentModalViewController:_imagePicker animated:YES];	
//}
//
//- (IBAction)miscClicked:(id)sender {
//    printf("[MVC] Misc clicked!\n");
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	[appDelegate displayView:2];
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
//	// Dismiss the image selection, hide the picker and show the image view with the picked image
//	[picker dismissModalViewControllerAnimated:YES];
//	_imagePicker.view.hidden = YES;
//	imageView.image = img;
//	imageView.hidden = NO;
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//	[appDelegate.window bringSubviewToFront:imageView];
//}
//
//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    printf("[MVC] Touched\n");
//    if (imageView.hidden == NO) {
//        printf("[MVC] Touched in imageView\n");
//        imageView.hidden = YES;
//    }
//}
//@end
