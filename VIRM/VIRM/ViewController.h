//
//  ViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQE.h"

@interface ViewController : UIViewController <IQEDelegate> {
    IQE* iqengines;
}
- (IBAction)cameraClicked:(id)sender;

@end
