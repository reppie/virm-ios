//
//  HistoryItemDataController.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryItemDataController.h"
#import "HistoryItem.h"

@interface HistoryItemDataController ()
-(void)initializeDefaultDataList;
@end

@implementation HistoryItemDataController

@synthesize historyList = _historyList;

-(id)init {
    if(self = [super init]) {
        printf("[History] Initializing.\n");
        [self initializeDefaultDataList];
        return self;
    }
    return nil;
}

-(void)initializeDefaultDataList {
    printf("[History] Initializing Default Data List.\n");    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    self.historyList = list;

}

-(void)setHistoryList:(NSMutableArray *)historyList:(NSMutableArray *)newList{
    if(_historyList != newList) {
        _historyList = [newList mutableCopy];
    }
}

-(unsigned)countOfList {
    return [self.historyList count];
}

-(HistoryItem *)objectInListAtIndex:(unsigned int)theIndex {
    return [self.historyList objectAtIndex:theIndex];
}

-(HistoryItem *)getLastAddedHistoryItem {
    return [self objectInListAtIndex:[self countOfList]-1];
}

-(void)addHistoryItem:(NSString *)name painter:(NSString *)painter image:(UIImage *)image {
    printf("[History] Adding history item.\n");
    HistoryItem *historyItem;
    NSDate *today = [[NSDate alloc] init];
    historyItem = [[HistoryItem alloc] initWithName:name painter:painter image:image date:today];
    [self.historyList addObject:historyItem];
    printf("[History] List count: %i\n", self.historyList.count);
    
}

-(void)addHistoryItem:(HistoryItem *) historyItem {
    printf("[History] Adding history item.\n");
    historyItem = [[HistoryItem alloc] initWithName:historyItem.name painter:historyItem.painter image:historyItem.image date:historyItem.date];
    [self.historyList addObject:historyItem];
    printf("[History] List count: %i\n", self.historyList.count);
}

@end
