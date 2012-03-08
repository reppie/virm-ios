//
//  MainViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiViewController : UIViewController <UIImagePickerControllerDelegate>{
}

@property (strong, nonatomic) UIImagePickerController *imagePicker;

//- (IBAction)cameraClicked:(id)sender;
//- (IBAction)libraryClicked:(id)sender;
//- (IBAction)miscClicked:(id)sender;
//
//- (void)imagePickerController:(UIImagePickerController *)picker
//        didFinishPickingImage:(UIImage *)image
//                  editingInfo:(NSDictionary *)editingInfo;

- (void) displayView:(int)intNewView;

@end
