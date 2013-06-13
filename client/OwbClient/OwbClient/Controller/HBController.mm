//
//  HBController.m
//  OwbClient
//
//  Created by Jack on 19/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "HBController.h"
static HBController *instance = nil;
@implementation HBController

+ (HBController *)SharedHBController {
    if (nil == instance) {
        instance = [[HBController alloc] init];
    }
    return instance;
}

- (void)hearHBWithUserName:(NSString *)userName withMeetingCode:(NSString *)meetingCode
{
    meetingCode_ = meetingCode;
    hbSendPack = [[OwbClientHeartSendPackage alloc] init];
    try {
        [hbSendPack setMeetingId_:meetingCode];
        [hbSendPack setUserName_:userName];
    } catch (std::exception e) {
//        NSLog(@"in HBController.mm: fail to start hear.");
    }
    
    [self performSelectorInBackground:@selector(heartBeat) withObject:nil];
}

- (int)heartBeat
{
    while (true) {
        if(shouldStop){
            break;
        } else {
            OwbClientHeartReturnPackage *hbRetrunPack;
            try {
                hbRetrunPack = [[OwbClientServerDelegate sharedServerDelegate] heartBeat:hbSendPack];
                [self analysisReturnPack:hbRetrunPack.identity_];
            } catch (std::exception e) {
                if (failCount++>MAX_FAIL) {
                    shouldStop=YES;
                    [hbDelegate_ alert];
                    
                }
            }
        }
        sleep(SLEEP_TIME);
    }
}

- (void)analysisReturnPack:(enum OwbIdentity)identity
{
    if(!isNotFirst&&OwbHOST!=identity) {
        [[QueueHandler SharedQueueHandler] startQueueGetDataBackgroundWithMeetingID:hbSendPack.meetingId_];
        isNotFirst=YES;
    }
    NSLog(@"is host?: %d", identity);
    NSLog(@"Board inHost: %d", [[BoardModel SharedBoard] inHostMode_]);
    if([[BoardModel SharedBoard] inHostMode_] && OwbHOST!=identity) {
        [self sendTillOver];
        NSLog(@"1 is host: %d", [[BoardModel SharedBoard] inHostMode_]);

    } else if(![[BoardModel SharedBoard] inHostMode_] && OwbHOST==identity) {
        NSLog(@"2 is host: %d", [[BoardModel SharedBoard] inHostMode_]);
        [[QueueHandler SharedQueueHandler] stopQueueGetDataBackground];
        [self getLatestDoc];
//        [self.hbDelegate_ hint:HOST_HINT];
        [[BoardModel SharedBoard] setInHostMode_:YES];
    }
}

- (void)stopHear
{
    shouldStop = YES;
}

- (NSString *)getMeetingCode
{
    return meetingCode_;
}

- (bool)sendTillOver
{
    if ([[QueueHandler SharedQueueHandler]sendIsOver]) {
//        [self.hbDelegate_ hint:HOST_HINT];
        [[BoardModel SharedBoard] setInHostMode_:NO];
        [self getLatestDoc];
        [[QueueHandler SharedQueueHandler] startQueueGetDataBackgroundWithMeetingID:hbSendPack.meetingId_];
        return true;
    }
    return false;
}

- (void)getLatestDoc
{
    try {
        OwbClientDocument *latestSnapshot = [[OwbClientServerDelegate sharedServerDelegate] getLatestDocument:meetingCode_];
        [[QueueHandler SharedQueueHandler]setLatestSeriaNumber:latestSnapshot.serialNumber_];
        [[BoardModel SharedBoard] loadDocumentAsync:latestSnapshot];
        [[QueueHandler SharedQueueHandler] clear];
    } catch (std::exception e) {
        [hbDelegate_ alert];
    }
}
@end
