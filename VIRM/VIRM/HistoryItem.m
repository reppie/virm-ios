//
//  HistoryItem.m
//  VIRM
//
//  Created by Clockwork Clockwork on 3/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HistoryItem.h"

@implementation HistoryItem

@synthesize image = _image, name = _name, painter = _painter, date = _date;

-(id)initWithName:(NSString *)name painter: (NSString *)painter image:(UIImage *)image date:(NSDate *) date{
    self = [super init];
    if (self) {
        _name = name;
        _painter = painter;
        _image = image;
        _date = date;
        return self;
    }
    return nil;
}


@end