//
//  HistoryItem.h
//  VIRM
//
//  Created by Clockwork Clockwork on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryItem : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *painter;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSDate *date;

-(id)initWithName:(NSString *)name painter:(NSString *)painter image:(UIImage *)image date:(NSDate *)date;

@end
