//
//  AppDelegate.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MSScanner.h"
#import "HistoryItemDataController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, MSScannerDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HistoryItemDataController *historyItemDataController;

- (void) processResult: (NSString *) imageId;

@end
