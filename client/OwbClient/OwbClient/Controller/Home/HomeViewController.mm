//
//  HomeViewController.m
//  OwbClient
//
//  Created by  tsgsz on 4/7/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "HomeViewController.h"
#import "LoginViewController.h"
#import "MeetingCodeViewController.h"
#import "OwbCommon.h"

@interface HomeViewController()

@property (strong, nonatomic) LoginViewController *loginViewController_;
@property (strong, nonatomic) MeetingCodeViewController *createMeetingCodeView_;
@property (strong, nonatomic) MeetingCodeViewController *joinMeetingCodeView_;
@property (strong, nonatomic) CanvasViewController *canvasView_;
@property (strong, nonatomic) NSString *meetingCode_;
@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *createBtn;
@property (strong, nonatomic) UIButton *joinBtn;

@end
BOOL isFailed = NO;
@implementation HomeViewController

- (void)loadView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [[OwbClientServerDelegate sharedServerDelegate] bindMonitorIp:[defaults stringForKey:@"MIP"] AndPort:[defaults integerForKey:@"MP"]];
    [[OwbClientServerDelegate sharedServerDelegate] bindProviderIp:[defaults stringForKey:@"PIP"] AndPort:[defaults integerForKey:@"PP"]];
    
//    NSLog(@"ip and port: \n%@ %@ %@ %@", [defaults objectForKey:@"MIP"], [defaults objectForKey:@"MP"], [defaults objectForKey:@"PIP"], [defaults objectForKey:@"PP"]);
    
    user = [[OwbClientUser alloc] init];
    //    ServerDelegate::GetInstance()->login([[[OwbClientUser alloc]init]toUser]);
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
    [self.view setBackgroundColor:background];
    
    // login view
    self.loginViewController_ = [[LoginViewController alloc]initWithStyle:UITableViewStyleGrouped];
    self.loginViewController_.loginDelegate_ = self;
    [self.view addSubview:self.loginViewController_.view];
    [self.loginViewController_.view setHidden:YES];
    
    // create meeting code view
    self.createMeetingCodeView_ = [[MeetingCodeViewController alloc]initWithStyle:UITableViewStyleGrouped withType:CREATE_BTN_STR];
    [self.view addSubview:self.createMeetingCodeView_.view];
    [self.createMeetingCodeView_.view setHidden:YES];
    
    // join meeting code view
    self.joinMeetingCodeView_ = [[MeetingCodeViewController alloc]initWithStyle:UITableViewStyleGrouped withType:JOIN_BTN_STR];
    self.joinMeetingCodeView_.meetingCodeDelegate_ = self;
    [self.view addSubview:self.joinMeetingCodeView_.view];
    [self.joinMeetingCodeView_.view setHidden:YES];
    
    // buttons
    self.loginBtn = [[UIButton alloc] initWithFrame:LOGIN_BTN_FRAME];
    [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"login1.png"] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"loginPress.png"] forState:UIControlStateHighlighted];
    [self.loginBtn addTarget:self action:@selector(loginBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    self.createBtn = [[UIButton alloc] initWithFrame:CREATE_BTN_FRAME];
    [self.createBtn setBackgroundImage:[UIImage imageNamed:@"create.png"] forState:UIControlStateNormal];
    [self.createBtn setBackgroundImage:[UIImage imageNamed:@"createPress.png"] forState:UIControlStateHighlighted];
    [self.createBtn addTarget:self action:@selector(createBtnPress:) forControlEvents:UIControlEventTouchUpInside];
//    self.createBtn 
    self.joinBtn = [[UIButton alloc] initWithFrame:JOIN_BTN_FRAME];
    [self.joinBtn setBackgroundImage:[UIImage imageNamed:@"join.png"] forState:UIControlStateNormal];
    [self.joinBtn setBackgroundImage:[UIImage imageNamed:@"joinPress.png"] forState:UIControlStateHighlighted];

    [self.joinBtn addTarget:self action:@selector(joinBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginBtn];
    [self.view addSubview:self.createBtn];
    [self.view addSubview:self.joinBtn];
    self.createBtn.userInteractionEnabled = NO;
    self.joinBtn.userInteractionEnabled = NO;
    // canvas
    self.canvasView_ =[[CanvasViewController alloc] init];
    [self.view addSubview:self.canvasView_.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - btn action listeners
- (void)loginBtnPress:(id) sender
{
    if (self.loginViewController_.view.isHidden == YES) {
        [self.createMeetingCodeView_.view setHidden:YES];
        [self.joinMeetingCodeView_.view setHidden:YES];
        [self.loginViewController_.view setAlpha:0];
        [self.loginViewController_.view setHidden:NO];
        [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveLinear animations:^{
            [self.loginViewController_.view setAlpha:1];
        } completion:^(BOOL finished) {
            
        }];
    } else {
//        [self login];
    }
}

- (void)login
{
    [user setUserName_:self.loginViewController_.userName_];
    [user setPassWord_:self.loginViewController_.userPswd_];
    int isLogin = 0;
    try {
        isLogin=[[OwbClientServerDelegate sharedServerDelegate] login:user];
    } catch (std::exception) {
        isLogin=2;
    }
    if (1==isLogin) {
        self.createBtn.userInteractionEnabled = YES;
        self.joinBtn.userInteractionEnabled = YES;
        self.loginViewController_.view.hidden = YES;
        [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"logout.png"] forState:UIControlStateNormal];
        [self.loginBtn setBackgroundImage:[UIImage imageNamed:@"logoutPress.png"] forState:UIControlStateNormal];

        [self.joinMeetingCodeView_ setUser:user];
        SUCCESS_HUD(@"登录成功！");
    } else if(0==isLogin){
        ERROR_HUD(LOGIN_FAIL);
    } else {
        ERROR_HUD(NETWORK_ERROR);
    }
}

- (void)createBtnPress:(id) sender
{
    [self.loginViewController_.view setHidden:YES];
    [self.joinMeetingCodeView_.view setHidden:YES];
    [self.createMeetingCodeView_.view setAlpha:0];
    [self.createMeetingCodeView_.view setHidden:NO];
    [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveLinear animations:^{
        [self.createMeetingCodeView_.view setAlpha:1];
    } completion:^(BOOL finished) {
        TRY(self.createMeetingCodeView_.meetingCode_ = [[OwbClientServerDelegate sharedServerDelegate] createMeeting:user.userName_]);
        [self.createMeetingCodeView_.tableView reloadData];
    }];
}

- (void)joinBtnPress:(id) sender
{
    [self.loginViewController_.view setHidden:YES];
    [self.createMeetingCodeView_.view setHidden:YES];
    [self.joinMeetingCodeView_.view setAlpha:0];
    [self.joinMeetingCodeView_.view setHidden:NO];
    [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveLinear animations:^{
        [self.joinMeetingCodeView_.view setAlpha:1];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - delegates
- (void)showCanvas:(NSString *)meetingCode
{
    self.meetingCode_ = meetingCode;
    NSLog(@"show canvas...");
    
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
	HUD.delegate = self;
	HUD.labelText = LOADING;
	
	[HUD showWhileExecuting:@selector(tryToStartMeeting) onTarget:self withObject:nil animated:YES];
    if(isFailed) {
        
    }
}

- (void)tryToStartMeeting
{
    if([self.canvasView_ startMeeting:self.meetingCode_ withUserName:user.userName_]) {
        [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
            self.canvasView_.view.frame = CANVAS_OPEN_FRAME;
        } completion:^(BOOL finished) {
            [self.canvasView_ displayerWillRefresh:[BoardModel SharedBoard]];
        }];
    } else {
        isFailed = YES;
        ERROR_HUD(NETWORK_ERROR);
    }
}
@end
