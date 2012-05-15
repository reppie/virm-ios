//
//  AppDelegate.h
//  VIRM
//
//  Created by Clockwork Clockwork on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryItemDataController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, assign) int maxDistance;
@property (nonatomic, assign) int matchesNeeded;
@property (nonatomic, assign) int imageDimensions;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HistoryItemDataController *historyItemDataController;

- (void) setDefaultValues;

@end
