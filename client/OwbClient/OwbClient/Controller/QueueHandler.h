//
//  QueueHandler.h
//  OwbClient
//
//  Created by Jack on 30/4/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OwbCommon.h"

@interface QueueHandler : NSObject <DrawerDelegate, MBProgressHUDDelegate>{
    __block OwbClientOperationQueue *opQueue_;
    __block OwbClientOperation *operation_;
    __block NSString *meetingCode_;
    __block bool shouldStop_;
    dispatch_queue_t sendQueue;
}

+ (QueueHandler *)SharedQueueHandler;
- (void)startQueueGetDataBackgroundWithMeetingID:(NSString *)meetingID;
- (void)stopQueueGetDataBackground;
- (void)drawOperationToServer:(OwbClientOperation *)op;
- (void)setMeetingCode:(NSString *)code;
- (void)setLatestSeriaNumber:(int) num;
- (bool)sendIsOver;
- (void)clear;
@end
