//
//  UserListViewController.h
//  OwbClient
//
//  Created by Jack on 21/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OwbCommon.h"
#import "UIScrollView+SVPullToRefresh.h"

@protocol SetDrawableDelegate <NSObject>

- (void)closeDraw;

@end


@interface UserListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate> {
@private
    OwbClientUserList *ul_;
    NSString *mCode_;
}
@property (nonatomic, retain) id<SetDrawableDelegate> setDrawableDelegate_;
- (void)setUserList:(OwbClientUserList *)list;
- (void)setMeetingID:(NSString *)meetingCode;
@end
