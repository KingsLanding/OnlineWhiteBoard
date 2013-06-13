//
//  OperationWrapper.m
//  OwbClient
//
//  Created by Jack on 28/4/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import "OperationWrapper.h"
//#define initPosition(a) CGPointMake((a.x+self.offX_)*self.scale_, (a.y+self.offY_)*self.scale_)

#define realPosition(a) CGPointMake(a.x*self.scale_+self.offX_, a.y*self.scale_+self.offY_)
#define unrealPosition(a) CGPointMake((a.x-self.offX_)/self.scale_, (a.y-self.offY_)/self.scale_)
#define screenStart self.start_//CGPointMake((self.start_.x-self.offX_)*self.scale_, (self.start_.y-self.offY_)*self.scale_)
#define screenEnd self.end_//CGPointMake((self.end_.x-self.offX_)*self.scale_, (self.end_.y-self.offY_)*self.scale_)

static OperationWrapper *instance = nil;
DrawPoint *midDrawPoint;
DrawLine *midDrawLine;
DrawRectange *midDrawRect;
DrawEllipse *midDrawEllipse;
Erase *midErase;

@implementation OperationWrapper
+ (OperationWrapper *)SharedOperationWrapper {
    if (nil == instance) {
        instance = [[OperationWrapper alloc] init];
        instance.opType_ = POINT;
        instance.alpha_ = 1.0;
        instance.thickness_ = 4;
        instance.color_ = 0;
        instance.scale_ = 1;
        instance.isFilled = NO;
        midDrawPoint = [[DrawPoint alloc] init];
        midDrawLine = [[DrawLine alloc] init];
        midDrawRect = [[DrawRectange alloc] init];
        midDrawEllipse = [[DrawEllipse alloc] init];
        midErase = [[Erase alloc] init];
        instance.rid = new int[5];
        instance.rid[POINT] = [midDrawPoint.drawer_ registerDataSource];
        instance.rid[ERASER] = [midErase.drawer_ registerDataSource];
    }
    return instance;
}

- (OwbClientOperation *)wrap
{
    switch (self.opType_) {
        case POINT:
        {
            DrawPoint *drawPoint = [[DrawPoint alloc] init];
            [drawPoint setColor_:self.color_];
            [drawPoint setThinkness_:self.thickness_*self.scale_ ];
            drawPoint.alpha_ = self.alpha_;
            drawPoint.position_ = realPosition(self.end_);
            [drawPoint setIsStart_:self.is_start_];
//            NSLog(@"-------------%d---------------",drawPoint.isStart_);
//            NSLog(@"wrap op thinkness %d",drawPoint.thinkness_);

            self.is_start_ = NO;
            return drawPoint;
        }
            break;
        case LINE:
        {
            DrawLine *drawLine = [[DrawLine alloc] init];
            drawLine.color_ = self.color_;
            drawLine.thinkness_ = self.thickness_*self.scale_;
            drawLine.alpha_ = self.alpha_;
            drawLine.startPoint_ = realPosition(self.start_);
            drawLine.endPoint_ = realPosition(self.end_);
//            NSLog(@"-------Line----");
            return drawLine;
            
        }
            break;
        case RECT:
        {
            DrawRectange *drawRect = [[DrawRectange alloc] init];
            drawRect.color_ = self.color_;
            drawRect.thinkness_ = self.thickness_*self.scale_;
            drawRect.alpha_ = self.alpha_;
            drawRect.topLeftCorner_ = realPosition(self.start_);
            drawRect.bottomRightCorner_ = realPosition(self.end_);
            [drawRect setFill_:self.isFilled];
            return drawRect;
        }
            break;
        case ELLIPSE:
        {
            DrawEllipse *drawEllipse = [[DrawEllipse alloc] init];
            drawEllipse.color_ = self.color_;
            drawEllipse.thinkness_ = self.thickness_*self.scale_;
            drawEllipse.alpha_ = self.alpha_;
            drawEllipse.center_ = realPosition(CGPointMake((self.start_.x+self.end_.x)/2, (self.start_.y+self.end_.y)/2));
            drawEllipse.a_ = fabs(realPosition(self.start_).x-realPosition(self.end_).x)/2;
            drawEllipse.b_ = fabs(realPosition(self.start_).y-realPosition(self.end_).y)/2;
//            NSLog(@"{{{{{ center: %f, %f; a: %f, b: %f ; left top: (%f, %f)}}}}}", drawEllipse.center_.x, drawEllipse.center_.y, drawEllipse.a_, drawEllipse.b_, (self.start_.x+self.end_.x), (self.start_.y+self.end_.y));
            [drawEllipse setFill_:self.isFilled];
            return drawEllipse;
        }
            break;
        case ERASER:
        {
            Erase *erase = [[Erase alloc] init];
            erase.thinkness_ = 8*self.thickness_*self.scale_;
            erase.position_ = realPosition(self.end_);
            erase.isStart_ = self.is_start_;
            self.is_start_ = NO;
            return erase;
        }
            break;
    }
}

- (OwbClientOperation *)wrapMiddle
{
    switch (self.opType_) {
        case POINT:
        {
            DrawPoint *drawPoint = [[DrawPoint alloc] init];
            drawPoint.color_ = self.color_;
            drawPoint.thinkness_ = self.thickness_;
            drawPoint.alpha_ = self.alpha_;
            drawPoint.position_ = screenEnd;
            drawPoint.isStart_ = self.is_start_;
            //            NSLog(@"****** point is start: %d *******", drawPoint.isStart_);
            self.is_start_ = NO;
            return drawPoint;
        }
            break;
        case LINE:
        {
            DrawLine *drawLine = [[DrawLine alloc] init];
            drawLine.color_ = self.color_;
            drawLine.thinkness_ = self.thickness_;
            drawLine.alpha_ = self.alpha_;
            drawLine.startPoint_ = screenStart ;
            drawLine.endPoint_ = screenEnd;
//            NSLog(@"-------Line----");
            return drawLine;
            
        }
            break;
        case RECT:
        {
            DrawRectange *drawRect = [[DrawRectange alloc] init];
            drawRect.color_ = self.color_;
            drawRect.thinkness_ = self.thickness_;
            drawRect.alpha_ = self.alpha_;
            drawRect.topLeftCorner_ = screenStart;
            drawRect.bottomRightCorner_ = screenEnd;
//            NSLog(@"==M== scale: %f; x: %f; y: %f", self.scale_, self.offX_, self.offY_);
//            NSLog(@"====== rect topLeft: (%f, %f); bottomRight: (%f, %f) =========", drawRect.topLeftCorner_.x, drawRect.topLeftCorner_.y, drawRect.bottomRightCorner_.x, drawRect.bottomRightCorner_.y);
            [drawRect setFill_:self.isFilled];
            return drawRect;
        }
            break;
        case ELLIPSE:
        {
            DrawEllipse *drawEllipse = [[DrawEllipse alloc] init];
            drawEllipse.color_ = self.color_;
            drawEllipse.thinkness_ = self.thickness_;
            drawEllipse.alpha_ = self.alpha_;
            drawEllipse.center_ = (CGPointMake((screenStart.x+screenEnd.x)/2, (screenStart.y+screenEnd.y)/2));
            drawEllipse.a_ = fabs((screenStart).x-(screenEnd).x)/2;
            drawEllipse.b_ = fabs((screenStart).y-(screenEnd).y)/2;
//            NSLog(@"{{{{{ center: %f, %f; a: %f, b: %f ; left top: (%f, %f)}}}}}", drawEllipse.center_.x, drawEllipse.center_.y, drawEllipse.a_, drawEllipse.b_, (self.start_.x+self.end_.x), (self.start_.y+self.end_.y));
            [drawEllipse setFill_:self.isFilled];
            return drawEllipse;
        }
            break;
        case ERASER:
        {
            Erase *erase = [[Erase alloc] init];
            erase.thinkness_ = 8*self.thickness_;
            erase.position_ = realPosition(self.end_);
            erase.isStart_ = self.is_start_;
            self.is_start_ = NO;
            return erase;
        }
            break;
    }
}

- (OwbClientOperation *)unwrap:(OwbClientOperation *)wrappedOp
{
    switch (wrappedOp.operationType_) {
        case POINT:
        {
            DrawPoint *drawPoint = [[DrawPoint alloc] init];
            drawPoint.color_ = ((DrawPoint *)wrappedOp).color_;
//            NSLog(@"unwrap----scale: %f", [[OperationWrapper SharedOperationWrapper] scale_]);
            drawPoint.thinkness_ = ((DrawPoint *)wrappedOp).thinkness_/self.scale_;
//            NSLog(@"new op thinkness %d",drawPoint.thinkness_);
            drawPoint.alpha_ = ((DrawPoint *)wrappedOp).alpha_;
            drawPoint.position_ = unrealPosition(((DrawPoint *)wrappedOp).position_);
            drawPoint.isStart_ = ((DrawPoint *)wrappedOp).isStart_;
//            NSLog(@"+++++++++++++++++%d++++++++++++++++++",drawPoint.isStart_);
//            NSLog(@"un wrap op thinkness %d",drawPoint.thinkness_);
//            NSLog(@"****** point is start: %d *******", drawPoint.isStart_);
            return drawPoint;
        }
            break;
        case LINE:
        {
            DrawLine *drawLine = [[DrawLine alloc] init];
            drawLine.color_ =  ((DrawLine *)wrappedOp).color_;
            drawLine.thinkness_ =  ((DrawLine *)wrappedOp).thinkness_/self.scale_;
            drawLine.alpha_ =  ((DrawLine *)wrappedOp).alpha_;
            drawLine.startPoint_ = unrealPosition( ((DrawLine *)wrappedOp).startPoint_);
            drawLine.endPoint_ = unrealPosition( ((DrawLine *)wrappedOp).endPoint_);
            //            NSLog(@"-------Line----");
            return drawLine;
            
        }
            break;
        case RECT:
        {
            DrawRectange *drawRect = [[DrawRectange alloc] init];
            drawRect.color_ = ((DrawRectange *)wrappedOp).color_;
            drawRect.thinkness_ = ((DrawRectange *)wrappedOp).thinkness_/self.scale_;
            drawRect.alpha_ = ((DrawRectange *)wrappedOp).alpha_;
            drawRect.topLeftCorner_ = unrealPosition(((DrawRectange *)wrappedOp).topLeftCorner_);
            drawRect.bottomRightCorner_ = unrealPosition(((DrawRectange *)wrappedOp).bottomRightCorner_);
//            NSLog(@"~~~~scale: %f", self.scale_);
            [drawRect setFill_:((DrawRectange *)wrappedOp).fill_];
            return drawRect;
        }
            break;
        case ELLIPSE:
        {
            DrawEllipse *drawEllipse = [[DrawEllipse alloc] init];
            drawEllipse.color_ = ((DrawEllipse *)wrappedOp).color_;
            drawEllipse.thinkness_ = ((DrawEllipse *)wrappedOp).thinkness_/self.scale_;
            drawEllipse.alpha_ = ((DrawEllipse *)wrappedOp).alpha_;
            drawEllipse.center_ = unrealPosition(((DrawEllipse *)wrappedOp).center_);
            drawEllipse.a_ = fabs(((DrawEllipse *)wrappedOp).a_/self.scale_);
            drawEllipse.b_ = fabs(((DrawEllipse *)wrappedOp).b_/self.scale_);
//            NSLog(@"}}}}} center: %f, %f; a: %f, b: %f ; left top: (%f, %f){{{{{", drawEllipse.center_.x, drawEllipse.center_.y, drawEllipse.a_, drawEllipse.b_, (self.start_.x+self.end_.x), (self.start_.y+self.end_.y));
            [drawEllipse setFill_:((DrawEllipse *)wrappedOp).fill_];
            return drawEllipse;
        }
            break;
        case ERASER:
        {
            Erase *erase = [[Erase alloc] init];
            erase.thinkness_ = ((Erase *)wrappedOp).thinkness_/self.scale_;
            erase.position_ = unrealPosition(((Erase *)wrappedOp).position_);
            erase.isStart_ = ((Erase *)wrappedOp).isStart_;
            return erase;
        }
            break;
    }
}
@end
