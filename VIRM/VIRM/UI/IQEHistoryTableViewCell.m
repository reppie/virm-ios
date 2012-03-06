/*
 Copyright (c) 2011-2012 IQ Engines, Inc.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

//
//  IQEHistoryTableViewCell.m
//

#import "IQEHistoryTableViewCell.h"

#define CELL_MARGIN 4

@implementation IQEHistoryTableViewCell

@synthesize imageViewSize;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        imageViewSize = CGSizeZero;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (CGSizeEqualToSize(imageViewSize, CGSizeZero))
         imageViewSize = self.imageView.frame.size;
        
    self.imageView.frame = CGRectMake(CELL_MARGIN,
                                      (self.frame.size.height - imageViewSize.height) / 2.0,
                                      imageViewSize.width,
                                      imageViewSize.height);
    
    CGFloat textLabelX = self.imageView.frame.origin.x + self.imageView.frame.size.width + CELL_MARGIN + CELL_MARGIN;
    CGFloat textLabelW = self.accessoryView ? self.accessoryView.frame.origin.x - textLabelX - CELL_MARGIN
                                            : self.frame.size.width             - textLabelX - CELL_MARGIN;
    
    self.textLabel.frame = CGRectMake(textLabelX,
                                      self.textLabel.frame.origin.y,
                                      textLabelW,
                                      self.textLabel.frame.size.height);
}

@end
