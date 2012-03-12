//
//  AppDelegate.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    printf("[DELEGATE] Finished launching\n");
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    
    viewController = [[CameraViewController alloc] init];
}

@end