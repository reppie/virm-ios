//
//  HistoryItemViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryItem;

@interface HistoryItemViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) HistoryItem *historyItem;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
