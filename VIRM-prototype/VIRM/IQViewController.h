//
//  IQViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQE.h"

@interface IQViewController : UIViewController <IQEDelegate> {
    IQE* iqengines;
}

@end
