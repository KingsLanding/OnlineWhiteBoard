//
//  MoveScaleImageView.m
//  OwbClient
//
//  Created by Jack on 21/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "MoveScaleImageView.h"
#import "CanvasViewController.h"
#define TEST_TIMES 1
//#define BoardIndex int(4-(scale-1)*2)
#define setOffsetX if ((offsetX+tmpX*boardScale)<0) { \
                         offsetX=0; \
                     } else if((offsetX+tmpX*boardScale+CanvasWidth*boardScale)>CanvasWidth*3) { \
                         offsetX+=0; \
                     } else { \
                         offsetX += tmpX*boardScale; \
                     }

#define setOffsetY if ((offsetY+tmpY*boardScale)<0) { \
                         offsetY=0; \
                     } else if((offsetY+tmpY*boardScale+CanvasHeight*boardScale)>CanvasHeight*3) { \
                         offsetY+=0; \
                     } else { \
                         offsetY += tmpY*boardScale; \
                     }

#define scaleOffsetX float tmpscaleOffsetX = offsetX - (CanvasWidth/2)*(boardScale-lastBoardScale); \
                     if (tmpscaleOffsetX<0) { \
                         offsetX=0; \
                     } else if((tmpscaleOffsetX+(CanvasWidth/2)*boardScale)>CanvasWidth*3) { \
                         offsetX+=0;  \
                     } else { \
                         offsetX = tmpscaleOffsetX; \
                     }

#define scaleOffsetY float tmpscaleOffsetY = offsetY - (CanvasHeight/2)*(boardScale-lastBoardScale); \
                     if (tmpscaleOffsetY<0) { \
                         offsetY=0; \
                     } else if((tmpscaleOffsetY+(CanvasHeight/2)*boardScale)>CanvasHeight*3) { \
                         offsetY+=0;   \
                     } else { \
                         offsetY = tmpscaleOffsetY; \
                     }

#define offsetScale (1.0/boardScale)//((4.0-scale)/3.0)
#define boardScale (3.0/((boardIndex_/2.0) + 1.0))
@implementation MoveScaleImageView

- (void)display
{
    CanvasViewController* canvasViewController = (CanvasViewController*)self.displayerDelegate_;
    [canvasViewController setBoardIndex:boardIndex_];
    [super display];
    [self setNeedsDisplay];
}

-(id)initWithFrame:(CGRect)frame{
	if (self=[super initWithFrame:frame]) {
//        NSLog(@"Board Data: %@", [[BoardModel SharedBoard] getData:BoardIndex]);
        [self setClearsContextBeforeDrawing:YES];
        self.isDrawable_ = [[BoardModel SharedBoard] inHostMode_];
//        UIImage *background = [UIImage imageWithCGImage: [[BoardModel SharedBoard] getData:BoardIndex]];
//        imageView.image = background;
//        [self sendSubviewToBack:imageView];
		[self setUserInteractionEnabled:YES];
		[self setMultipleTouchEnabled:NO];
		scale=1;
        boardIndex_=4;
        offsetX=0.0;
        offsetY=0.0;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        CanvasViewController* canvasViewController = (CanvasViewController*)self.displayerDelegate_;
        [canvasViewController refreshCurrentSnapshotBtn];
    });*/
    [super drawRect:rect];
    [displayImage_ drawInRect:rect];
//    NSLog(@"00000000");
    if (nil == middle_op_) {
        return;
    }
    if (isInMiddle_) {
        isInMiddle_ = NO;
        int rid = [OperationWrapper SharedOperationWrapper].rid[middle_op_.operationType_];
        [[middle_op_ drawer_]draw:middle_op_ InCanvas:UIGraphicsGetCurrentContext() WithResourceId:rid];
        middle_op_ = nil;
    }
}

-(void)setImage:(CGImageRef)imageRef{
//    CGImageRef tmpBoard = [[BoardModel SharedBoard] getData:BoardIndex];
    CGImageRef tmpShot = [self getScreenShot:imageRef];
    displayImage_ = [self setToFitScreen:tmpShot];
    CGImageRelease(tmpShot);
    
//    CGImageRelease(tmpBoard);
}

- (CGImageRef)getScreenShot:(CGImageRef)boardShot
{
//    NSLog(@"---- scale: %f; x: %f; y: %f", scale, offsetX, offsetY);
    return CGImageCreateWithImageInRect(boardShot, CGRectMake(offsetX*offsetScale, offsetY*offsetScale, CanvasWidth, CanvasHeight));
//    CGImageCreateCopy(boardShot);
}

- (UIImage *)setToFitScreen:(CGImageRef)screenShot
{
    UIGraphicsBeginImageContext(CGSizeMake(CanvasWidth, CanvasHeight));
    [[UIImage imageWithCGImage:screenShot] drawInRect:CGRectMake(0, 0, CanvasWidth, CanvasHeight)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([touches count]==2&& !self.isDrawable_) {//识别两点触摸,并记录两点间距离
//		NSArray* twoTouches=[touches allObjects];
//		originSpace=[self spaceToPoint:[[twoTouches objectAtIndex:0] locationInView:self]
//						FromPoint:[[twoTouches objectAtIndex:1]locationInView:self]];
//        NSLog(@"scale start");
//        NSLog(@"is drawable: %d", self.isDrawable_);
       
	}else if ([touches count]==3){
        
	}else if([touches count]==1 && self.isDrawable_){
//        NSLog(@"draw start");
        UITouch *touch=[touches anyObject];
		drawStartPoint=[touch locationInView:self];
        [[OperationWrapper SharedOperationWrapper] setStart_:drawStartPoint];
        if ([[OperationWrapper SharedOperationWrapper] opType_] == POINT || [[OperationWrapper SharedOperationWrapper] opType_] == ERASER) {
            [[OperationWrapper SharedOperationWrapper] setIs_start_:YES];
        } else {
            [[OperationWrapper SharedOperationWrapper] setIs_start_:NO];
        }
    } else if([touches count]==1 && !self.isDrawable_){
        // 记录移动开始
        UITouch *touch=[touches anyObject];
		gestureStartPoint=[touch locationInView:self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	if ([touches count]==2&& !self.isDrawable_) {
//		NSArray* twoTouches=[touches allObjects];
//		CGFloat currSpace=[self spaceToPoint:[[twoTouches objectAtIndex:0] locationInView:self]
//							 FromPoint:[[twoTouches objectAtIndex:1]locationInView:self]];
//		//如果先触摸一根手指，再触摸另一根手指，则触发touchesMoved方法而不是touchesBegan方法
//		//此时originSpace应该是0，我们要正确设置它的值为当前检测到的距离，否则可能导致0除错误
//		if (originSpace==0) {
//			originSpace=currSpace;
//		}
//		if (fabsf(currSpace-originSpace)>=min_offset) {//两指间移动距离超过min_offset，识别为手势“捏合”
//			CGFloat s=originSpace/currSpace;//计算缩放比例
////            NSLog(@"缩放比例：%f", s);
//			[self scaleTo:s];
//            [[OperationWrapper SharedOperationWrapper] setScale_:boardScale];
//			originSpace=currSpace;
//		} else {    // 两指合拢，识别为移动
//            
//        }
	}else if([touches count]==3){
		        
	}else if([touches count]==1 && self.isDrawable_){
        UITouch* touch=[touches anyObject];
		CGPoint currPoint=[touch locationInView:self];
        [[OperationWrapper SharedOperationWrapper] setEnd_:currPoint];
        [[OperationWrapper SharedOperationWrapper] setScale_:boardScale];
        if ([[OperationWrapper SharedOperationWrapper] opType_] == POINT || [[OperationWrapper SharedOperationWrapper] opType_] == ERASER) {
            OwbClientOperation *tmpOp = [[OperationWrapper SharedOperationWrapper] wrap];
//            NSLog(@"******** point tmp op: %@", tmpOp);
//            NSLog(@"tmp op thickness: %d", tmpOp.thinkness_);
//            NSLog(@"Move start");
//            [[BoardModel SharedBoard] drawOperation:tmpOp];
//            NSLog(@"@ end----scale: %f", [[OperationWrapper SharedOperationWrapper] scale_]);
            [[QueueHandler SharedQueueHandler] drawOperationToServer:tmpOp];
            [self drawOp:tmpOp];
        } else {
//            NSLog(@"------- middle shared operation type: %d, thinckness: %d", [[OperationWrapper SharedOperationWrapper] opType_], [[OperationWrapper SharedOperationWrapper] thickness_]);
            /*[[BoardModel SharedBoard] drawMiddleOperation:[[OperationWrapper SharedOperationWrapper] wrapMid]];*/
//            imageView.image = nil;
            middle_op_ = [[OperationWrapper SharedOperationWrapper] wrapMiddle];
            isInMiddle_ = YES;
            [self setNeedsDisplay];
        }
    }
    else if([touches count]==1 && !self.isDrawable_){
        UITouch* touch=[touches anyObject];
        CGPoint curr_point=[touch locationInView:self];
        //分别计算x，和y方向上的移动量
        tmpX=-(curr_point.x-gestureStartPoint.x);
        tmpY=-(curr_point.y-gestureStartPoint.y);
        
        
        setOffsetX;
        setOffsetY;
        //只要在任一方向上移动的距离超过Min_offset,判定手势有效
//        if(fabsf(tmpX)>= min_offset||fabsf(tmpY)>=min_offset){
            gestureStartPoint.x=curr_point.x;
            gestureStartPoint.y=curr_point.y;
//        }
        [[OperationWrapper SharedOperationWrapper] setOffX_:offsetX];
        [[OperationWrapper SharedOperationWrapper] setOffY_:offsetY];
//        NSLog(@"move scale offset: %f, %f", offsetX, offsetY);
        [self display];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if([touches count]==1 && self.isDrawable_){
        UITouch* touch=[touches anyObject];
		CGPoint currPoint=[touch locationInView:self];
        if ([[OperationWrapper SharedOperationWrapper] opType_] == POINT || [[OperationWrapper SharedOperationWrapper] opType_] == ERASER) {
        } else if([[OperationWrapper SharedOperationWrapper] opType_] == RECT){
            if(offsetX>0) {
                [[OperationWrapper SharedOperationWrapper] setEnd_:currPoint];
            } else {
                [[OperationWrapper SharedOperationWrapper] setEnd_:[[OperationWrapper SharedOperationWrapper] start_]];
                [[OperationWrapper SharedOperationWrapper] setStart_:currPoint];
            }
            [[OperationWrapper SharedOperationWrapper] setScale_:boardScale];
//            NSLog(@"end shared operation type: %d, thinckness: %d", [[OperationWrapper SharedOperationWrapper] opType_], [[OperationWrapper SharedOperationWrapper] thickness_]);
//            NSLog(@"end: (%f, %f)", drawStartPoint.x, drawStartPoint.y);
            
            OwbClientOperation *tmpOP = [[OperationWrapper SharedOperationWrapper] wrap];
            [[QueueHandler SharedQueueHandler] drawOperationToServer:tmpOP];

            [self drawOp:tmpOP];
//                [[BoardModel SharedBoard] drawOperation:[[OperationWrapper SharedOperationWrapper] wrap]];

        }else {
            [[OperationWrapper SharedOperationWrapper] setEnd_:currPoint];
            [[OperationWrapper SharedOperationWrapper] setScale_:boardScale];
//            NSLog(@"end shared operation type: %d, thinckness: %d", [[OperationWrapper SharedOperationWrapper] opType_], [[OperationWrapper SharedOperationWrapper] thickness_]);
            
            OwbClientOperation *tmpOp = [[OperationWrapper SharedOperationWrapper] wrap];
            [[QueueHandler SharedQueueHandler] drawOperationToServer:tmpOp];
            [self drawOp:tmpOp];
//                [[BoardModel SharedBoard] drawOperation:[[OperationWrapper SharedOperationWrapper] wrap]];
        }
    }
//    NSLog(@"scale: %f; x: %f; y: %f", scale, offsetX, offsetY);
}
- (int)getBoardIndex
{
    return boardIndex_;
}
-(void)scaleTo:(CGFloat)x{
	scale*=x;
	//缩放限制：>＝0.1，<=10
//    if(((offsetX+tmpX*boardScale+CanvasWidth*scale)>CanvasWidth*3)||((offsetY+tmpY*boardScale+CanvasHeight*scale)>CanvasHeight*3)) {
//    }
    [self scale];
}

- (void)scale
{
	scale=(scale<1)?1:scale;
	scale=(scale>3)?3:scale;
//    NSLog(@"1 scale: %f", scale);

    
    //    NSLog(@"scale before: %f", scale);
//    boardIndex_ = 4-floor((4*scale-3)/2);
    //    NSLog(@"index: %d", boardIndex_);
    scale = (float(6-boardIndex_))/2;
//    NSLog(@"2 scale: %f", scale);
//    NSLog(@"+++++++ offX: %f; offY: %f ++++++++", offsetX, offsetY);
    
    scaleOffsetX;
    scaleOffsetY;
    [[OperationWrapper SharedOperationWrapper] setOffX_:offsetX];
    [[OperationWrapper SharedOperationWrapper] setOffY_:offsetY];
//    NSLog(@"------- offX: %f; offY: %f --------", offsetX, offsetY);
    [self display];
}

-(CGFloat)spaceToPoint:(CGPoint)first FromPoint:(CGPoint)two{//计算两点之间的距离
	float x = first.x - two.x;
	float y = first.y - two.y;
	return sqrt(x * x + y * y);
}

- (void)drawOp:(OwbClientOperation *)operation
{
    [super drawOp:operation];

//    NSLog(@"draw op");
//    [[OperationWrapper SharedOperationWrapper] setScale_:boardScale];
    middle_op_ = [[OperationWrapper SharedOperationWrapper] unwrap:operation];
    [self setNeedsDisplay];
    UIGraphicsBeginImageContext(CGSizeMake(CanvasWidth, CanvasHeight));
    [displayImage_ drawAtPoint:CGPointZero];
    int rid = [OperationWrapper SharedOperationWrapper].rid[operation.operationType_];
    [[middle_op_ drawer_]draw:middle_op_ InCanvas:UIGraphicsGetCurrentContext() WithResourceId:rid];
    displayImage_ = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [[BoardModel SharedBoard] drawOperation:operation];

}

- (void)setScale:(int)s{
    lastBoardScale = boardScale;
    boardIndex_ = s;
    //    scale=s;
    [[OperationWrapper SharedOperationWrapper] setScale_:boardScale];

    [self scale];
}
@end
