//
//  HomeViewController.h
//  OwbClient
//
//  Created by  tsgsz on 4/7/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OwbCommon.h"
#import "CanvasViewController.h"
#import "MeetingCodeViewController.h"

@interface HomeViewController : UIViewController<LoginDelegate, MBProgressHUDDelegate, MeetingCodeDelegate> {
@private
    OwbClientUser *user;
}

@end
