//
//  AppDelegate.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSScanner.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MSScannerDelegate> {
    NSString *globalImageId;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *globalImageId;

@end
