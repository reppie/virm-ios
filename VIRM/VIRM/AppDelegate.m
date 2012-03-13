//
//  AppDelegate.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MSScanner.h"
#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    MSScanner *scanner = [MSScanner sharedInstance];
    [scanner open:nil];
    [scanner syncWithDelegate:self];
}

-(void)scannerWillSync:(MSScanner *)scanner
{
    printf("[Moodstocks] Will sync.\n");
}

- (void)scannerDidSync:(MSScanner *)scanner
{
    scanner = [MSScanner sharedInstance];
    NSInteger count = [scanner count:nil];
    printf("[Moodstocks] Did sync. Database size = %d image(s).\n", count);
}

- (void)scanner:(MSScanner *)scanner failedToSyncWithError:(NSError *)error
{
    ms_errcode ecode = [error code];
    if (ecode >= 0) {
        NSString *errStr;
        if (ecode == MS_BUSY)
            errStr = @"A sync is pending";
        else
            errStr = [NSString stringWithCString:ms_errmsg(ecode) encoding:NSUTF8StringEncoding];
        
        //NSLog("[MSScanner] Failed to sync with error: %@", errStr);
        printf("[Moodstocks] Failed to sync.\n");
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}



@end
