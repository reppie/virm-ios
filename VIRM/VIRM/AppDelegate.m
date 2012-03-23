//
//  AppDelegate.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MSScanner.h"
#import "AppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize historyItemDataController = _historyItemDataController;


- (void)processResult:(NSString *) imageId {
    if([imageId isEqualToString: @"test1234"]) {
        printf("[Moodstocks] Mona Lisa found!\n");
        UIImage *image = [UIImage imageNamed:@"mona_lisa.png"];
        [self.historyItemDataController addHistoryItem:@"Mona Lisa" painter:@"Leonardo Da Vinci" image:image];
    }
    else if([imageId isEqualToString: @"nachtwacht"]) {
        printf("[Moodstocks] De Nachtwacht found!\n");
        UIImage *image = [UIImage imageNamed:@"nachtwacht.jpg"];
        [self.historyItemDataController addHistoryItem:@"De Nachtwacht" painter:@"Rembrandt van Rijn" image:image];
    }
}

- (void)testDataBaseConnection {
    // Start request
    NSString *uniqueIdentifier = @"testApp";
    NSString *code = @"testCode";
    NSURL *url = [NSURL URLWithString:@"http://192.168.0.144/"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:@"1" forKey:@"rw_app_id"];
    [request setPostValue:code forKey:@"code"];
    [request setPostValue:uniqueIdentifier forKey:@"device_id"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{    
    printf("[Database] Connection succesful.");        
}

- (void)requestFailed:(ASIHTTPRequest *)request
{    
    NSError *error = [request error];
    printf("[Database] Error: %s.", [error.localizedDescription UTF8String]);
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    _historyItemDataController = [[HistoryItemDataController alloc] init];
    [self testDataBaseConnection];
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
