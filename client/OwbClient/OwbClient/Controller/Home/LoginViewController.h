//
//  LoginViewController.h
//  OwbClient
//
//  Created by  tsgsz on 4/8/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OwbCommon.h"

@protocol LoginDelegate <NSObject>

- (void)login;

@end

@interface LoginViewController : UITableViewController<UITextFieldDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) NSString *userName_, *userPswd_;
@property (nonatomic, retain) id<LoginDelegate> loginDelegate_;

@end