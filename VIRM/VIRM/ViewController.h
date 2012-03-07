//
//  ViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQE.h"
#import "AppDelegate.h"

@interface ViewController : UIViewController <UIImagePickerControllerDelegate>{
    IQE* iqengines;
    UIImageView* imageView;
}

@property (strong, nonatomic) UIImagePickerController *imagePicker;

- (IBAction)cameraClicked:(id)sender;
- (IBAction)libraryClicked:(id)sender;

- (void)applicationDidFinishLaunching:(UIApplication *)application;
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
