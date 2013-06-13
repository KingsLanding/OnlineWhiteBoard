//
//  SnapshotListViewController.h
//  OwbClient
//
//  Created by Jack on 21/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OwbCommon.h"
@protocol RefreshSnapshotDelegate <NSObject>

- (void)refreshCurrentSnapshotBtn;
- (void)setCanvasImage:(CGImageRef)imageRef;

@end



@interface SnapshotListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
@private
    OwbClientDocumentList *dl_;
    NSString *mCode_;
    int currentRow_;
}
@property(nonatomic, strong) UIButton *snapshotCurrentBtn_;
@property (nonatomic, retain) id<RefreshSnapshotDelegate> refreshSnapshotDelegate_;

- (void)setMeetingID:(NSString *)meetingCode;
@end
