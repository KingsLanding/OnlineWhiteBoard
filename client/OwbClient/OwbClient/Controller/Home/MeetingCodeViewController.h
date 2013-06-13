//
//  MeetingCodeViewController.h
//  OwbClient
//
//  Created by Jack on 12/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OwbCommon.h"

@protocol MeetingCodeDelegate
-(void)showCanvas:(NSString *)meetingCode;
@end

@interface MeetingCodeViewController : UITableViewController<UITextFieldDelegate, MBProgressHUDDelegate>{
@private
    OwbClientUser *user_;
}

@property(nonatomic, strong) NSString *meetingCode_;
@property id<MeetingCodeDelegate> meetingCodeDelegate_;

- (void)setUser:(OwbClientUser *)u;
- (id)initWithStyle:(UITableViewStyle)style withType:(NSString *)type;
@end