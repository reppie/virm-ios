//
//  HistoryItemDataController.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HistoryItem;

@interface HistoryItemDataController : NSObject

@property (nonatomic, retain) NSMutableArray *historyList;

-(unsigned)countOfList;
-(HistoryItem *)objectInListAtIndex:(unsigned)theIndex;
-(void)addHistoryItem:(NSString *)name painter:(NSString *)painter image:(UIImage *)image;
-(void)addHistoryItem:(HistoryItem *) historyItem;
-(HistoryItem *)getLastAddedHistoryItem;

@end
