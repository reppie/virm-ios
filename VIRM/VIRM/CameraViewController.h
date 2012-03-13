//
//  FirstViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController {
    UIImage *image;
    IBOutlet UIImageView *imageView;
    
    UIImagePickerController *picker;
}

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic, retain) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;

- (IBAction)cameraClicked:(id)sender;
- (IBAction)libraryClicked:(id)sender;

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo;
@end
