/*************************************************************************
     ** File Name: OwbClientOperationQueue.mm
    ** Author: tsgsz
    ** Mail: cdtsgsz@gmail.com
    ** Created Time: Mon Apr 22 14:16:31 2013
    **Copyright [2013] <Copyright tsgsz>  [legal/copyright]
 ************************************************************************/
#import "./OwbClientOperationQueue.h"

#import "../Models/MessageModel.h"
#import "../Server/OwbClientServerDelegate.h"
#include <exception>

@implementation OwbClientOperationQueue

@synthesize writable_ = _writable_;
@synthesize meetingId_ = _meetingId_;
@synthesize latestSerialNumber_ = _latestSerialNumber_;

- (id)init
{
    self = [super init];
    if(nil != self) 
    {
        operations_ = [[NSMutableArray alloc]init];
        enqueueLocker_ = [[NSRecursiveLock alloc]init];
        dequeueLocker_ = [[NSRecursiveLock alloc]init];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
    if (nil != _meetingId_) {
        [_meetingId_ release];
    }
}

- (void)enqueue:(OwbClientOperation *)operation
{
    [enqueueLocker_ lock];
    OwbClientOperation* op = [operation retain];
    [operations_ addObject : op];
    self.latestSerialNumber_ = [operation serialNumber_];
    [enqueueLocker_ unlock];
}

- (OwbClientOperation *)dequeue
{
    [dequeueLocker_ lock];
    OwbClientOperation* operation = [[operations_ objectAtIndex:0]retain];
    [operations_ removeObjectAtIndex:0];
    [dequeueLocker_ unlock];
    return operation;
}

- (bool)isEmpty
{
    return [operations_ count] == 0;
}

- (int)getServerData
{
    [self lock];
    try {
        OwbClientOperationList* opList = [[OwbClientServerDelegate sharedServerDelegate]getOperationList:self.meetingId_ LatestSerialNumber:self.latestSerialNumber_];
        if (OwbAVALIBLE != opList.operationAvaliable_) {
            [self unLock];
            return opList.operationAvaliable_;
        }
        if (0 == [opList.operationList_ count]) {
            [self unLock];
            return OwbNOT_UPDATE;
        }
        [operations_ addObjectsFromArray:opList.operationList_];
        self.latestSerialNumber_ = [((OwbClientOperation *) [opList.operationList_ lastObject]) serialNumber_];
        [self unLock];
        return opList.operationAvaliable_;
    } catch (std::exception e) {
        [self unLock];
        throw e;
    }

}

- (void)lock
{
    [enqueueLocker_ lock];
    [dequeueLocker_ lock];

}

- (void)unLock
{
    [enqueueLocker_ unlock];
    [dequeueLocker_ unlock];
}

- (void)clear
{
    [self lock];
    [operations_ removeAllObjects];
    [self unLock];
}

@end
