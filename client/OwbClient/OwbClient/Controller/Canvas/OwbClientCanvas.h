//
//  OwbClientCanvas.h
//  OwbClient
//
//  Created by Jack on 28/4/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OwbCommon.h"
#import "MoveScaleImageView.h"

@interface OwbClientCanvas : Canvas

@property(strong, nonatomic) MoveScaleImageView *scaleImageView;

- (void)initViewWithFrame:(CGRect)frame withImage:(CGImageRef)imageRef;

@end
