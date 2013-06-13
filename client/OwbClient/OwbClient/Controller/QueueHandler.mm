//
//  QueueHandler.m
//  OwbClient
//
//  Created by Jack on 30/4/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import "QueueHandler.h"
static QueueHandler * instance;
#define SENDQUEUE "sendQueue"
@implementation QueueHandler

+ (QueueHandler *)SharedQueueHandler {
    if (nil == instance) {
        instance = [[QueueHandler alloc] init];
    }
    return instance;
}

- (id) init {
    self = [super init];
    if (nil != self) {
        sendQueue = dispatch_queue_create(SENDQUEUE, NULL);
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    if (nil != sendQueue) {
        dispatch_release(sendQueue);
    }
}

-(void) setLatestSeriaNumber:(int)num {
    [opQueue_ setLatestSerialNumber_:num];
}

- (void)attachQueue:(OwbClientOperationQueue *)opQueue
{
    opQueue_ = opQueue;
    [opQueue_ setMeetingId_:meetingCode_];
}

- (void)startQueueGetDataBackgroundWithMeetingID:(NSString *)meetingID
{
    shouldStop_=NO;
    meetingCode_ = meetingID;
    [self performSelectorInBackground:@selector(getDataFromServer) withObject:nil];
}

- (void)getDataFromServer
{
    while (true) {
        sleep(SLEEP_SHORT_TIME);
        NSLog(@"HBHandler - getDataFromServer - start");
        if(shouldStop_) {
            NSLog(@"---------shouldStop---------");
            break;
        }
        OwbOperationAvaliable isSucToGetData;
        try {
            isSucToGetData = (OwbOperationAvaliable)[opQueue_ getServerData];
        } catch (std::exception e) {
            NSLog(@"in QueueHandler.mm: get server data failed.");
        }
        if(OwbAVALIBLE == isSucToGetData) {
            NSLog(@"Triger Read Operation");
            [[BoardModel SharedBoard] trigerReadOperationQueue];
        } else if(OwbNOT_AVALIABLE == isSucToGetData) {
            NSLog(@"op not avaliable ,try to get doc");
            OwbClientDocument *tmpDoc;
            try {
                tmpDoc = [[OwbClientServerDelegate sharedServerDelegate] getLatestDocument:meetingCode_];
                [opQueue_ setLatestSerialNumber_:tmpDoc.serialNumber_];
            } catch (std::exception e) {
                NSLog(@"in QueueHandler.mm: get latest doc failed.");
            }
            [[BoardModel SharedBoard] loadDocumentAsync:tmpDoc];
        }else if(OwbLOAD_DOCUMENT == isSucToGetData){
            NSLog(@"server has been set doc");
//            [opQueue_ setLatestSerialNumber_:(opQueue_.latestSerialNumber_+1)];
            OwbClientDocument *tmpDoc;
            try {
                tmpDoc = [[OwbClientServerDelegate sharedServerDelegate] getLatestDocument:meetingCode_];
                [opQueue_ setLatestSerialNumber_:tmpDoc.serialNumber_];
            } catch (std::exception e) {
                NSLog(@"in QueueHandler.mm: get latest doc failed.");
            }
            [[BoardModel SharedBoard] loadDocumentAsync:tmpDoc];
        }else if(OwbNOT_UPDATE == isSucToGetData){
            NSLog(@"no update");
        }
        
        NSLog(@"loop over");
    }
}

- (void)stopQueueGetDataBackground
{
    shouldStop_ = YES;
}

- (void)drawOperationToServer:(OwbClientOperation *)op
{
//    NSLog(@"opqueue isempty: %d", opQueue_.isEmpty);
    [opQueue_ enqueue:op];
    [self triggerWriteToServer];
}

- (void)triggerWriteToServer
{
    dispatch_async(sendQueue, ^(void){[self writeToServer];});
}

- (void)writeToServer
{
    while (true) {
        [opQueue_ lock];
        if ([opQueue_ isEmpty]) {
            [opQueue_ unLock];
            return;
        }
        [opQueue_ unLock];
        operation_ = [opQueue_ dequeue];
        while(![[OwbClientServerDelegate sharedServerDelegate] sendOperation:operation_]) {
            TRY([[OwbClientServerDelegate sharedServerDelegate] resumeUpdater:meetingCode_]);
        }
    }
}
- (void)setMeetingCode:(NSString *)code
{
    meetingCode_ = code;
}

-(bool)sendIsOver {
    return [opQueue_ isEmpty];
}

- (void)clear
{
    [opQueue_ clear];
}
@end
