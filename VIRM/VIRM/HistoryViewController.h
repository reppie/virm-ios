//
//  HistoryViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryItemViewController;
@class HistoryItemDataController;

@interface HistoryViewController : UITableViewController

@property (nonatomic, retain) HistoryItemDataController *dataController;
@property (strong, nonatomic) HistoryItemViewController *historyItemViewController;

@end
