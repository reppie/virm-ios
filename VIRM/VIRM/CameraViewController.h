//
//  FirstViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController {
    UIImageView* imageView;
}

@property (strong, nonatomic) UIImagePickerController *imagePicker;

- (IBAction)cameraClicked:(id)sender;
- (IBAction)libraryClicked:(id)sender;

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo;
@end
