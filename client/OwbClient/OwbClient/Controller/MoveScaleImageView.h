//
//  MoveScaleImageView.h
//  OwbClient
//
//  Created by Jack on 21/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OperationWrapper.h"
#import "OwbCommon.h"

#define min_offset 10 //定义手势最小移动距离为5，小于此距离的移动不处理

@interface MoveScaleImageView : Canvas{	
	CGPoint gestureStartPoint;//手势开始时起点
	CGFloat offsetX,offsetY;//移动时x,y方向上的偏移量
    CGPoint drawStartPoint;
	CGFloat originSpace;//两个手指的初始距离
    CGFloat tmpX,tmpY;  // 相对于（0，0）的绝对偏移（需要处以scale）
	CGFloat scale;//缩放比例
	CGRect lensRect;//设置镜头的大小
    
//    CGImageRef imageRef_;
    BOOL isInMiddle_;
    OwbClientOperation* middle_op_;
    UIImage* displayImage_;
    int boardIndex_;
    float lastBoardScale;
}
- (void)scale;
- (int)getBoardIndex;
- (void)setScale:(int)s;
- (void)display;
- (void)setImage:(CGImageRef)imageRef;
- (void)scaleTo:(CGFloat)x;
@end
