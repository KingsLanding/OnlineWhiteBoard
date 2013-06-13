//
//  CanvasViewController.h
//  OwbClient
//
//  Created by Jack on 13/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OwbCommon.h"
#import "MenuViewController.h"
#import "UserListViewController.h"
#import "SnapshotListViewController.h"
#import "OwbClientCanvas.h"

@interface CanvasViewController : UIViewController<MoveScaleDelegate, HBDelegate, MBProgressHUDDelegate, DisplayerDelegate, SetDrawableDelegate, RefreshSnapshotDelegate>

@property int boardIndex;
@property (strong, nonatomic) OwbClientCanvas *canvas_;
@property (strong, nonatomic) MenuViewController *menuVC_;

- (bool)switchDrawMethods;
- (bool)startMeeting:(NSString *)meetingCode withUserName:(NSString *)userName;
@end
