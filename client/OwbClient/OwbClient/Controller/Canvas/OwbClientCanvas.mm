//
//  OwbClientCanvas.m
//  OwbClient
//
//  Created by Jack on 28/4/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import "OwbClientCanvas.h"

@implementation OwbClientCanvas
- (void)display
{
    [self.displayerDelegate_ displayerWillRefresh:self.dataSource_];
}
- (void)initViewWithFrame:(CGRect)frame withImage:(CGImageRef)imageRef
{
    self.scaleImageView = [[MoveScaleImageView alloc]initWithFrame:frame];
    [self.scaleImageView setImage:imageRef];
}
@end
