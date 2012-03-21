//
//  PaintingViewController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryItem;

@interface PaintingViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) HistoryItem *historyItem;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
