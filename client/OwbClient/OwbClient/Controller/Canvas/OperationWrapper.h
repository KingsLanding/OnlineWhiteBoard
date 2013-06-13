//
//  OperationWrapper.h
//  OwbClient
//
//  Created by Jack on 28/4/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OwbCommon.h"

@interface OperationWrapper : NSObject {
}

@property int color_;
@property int thickness_;
@property float alpha_;
@property int opType_;
@property CGPoint start_;
@property CGPoint end_;
@property float scale_;
@property float offX_, offY_;
@property bool is_start_;
@property int* rid;
@property bool isFilled;

+ (OperationWrapper *)SharedOperationWrapper;
- (OwbClientOperation *)wrap;
- (OwbClientOperation *)wrapMiddle;
- (OwbClientOperation *)unwrap:(OwbClientOperation*) op;
@end
