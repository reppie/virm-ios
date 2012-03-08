//
//  AppDelegate.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MultiViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MultiViewController *viewController;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet MultiViewController *viewController;

-(void) displayView:(int)intNewView;

@end
