//
//  CanvasViewController.m
//  OwbClient
//
//  Created by Jack on 13/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "CanvasViewController.h"
#import "MenuViewController.h"
#import "MenuViewController.h"
#import "MenuViewController.h"
#import "MoveScaleImageView.h"

@interface CanvasViewController ()
@property bool isHost;
@property (strong, nonatomic) OwbClientOperationQueue *opQ_;
@property (strong, nonatomic) UserListViewController *userListVC_;
@property (strong, nonatomic) SnapshotListViewController *snapshotListVC_;
@property (strong, nonatomic) MoveScaleImageView *scaleView;

@property(nonatomic, strong) UIButton *moveBtn_;
@property(nonatomic, strong) UIButton *biggerBtn_;
@property(nonatomic, strong) UIButton *smallerBtn_;
@end

@implementation CanvasViewController
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:CANVAS_DEFAULT_FRAME];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.scaleView = [[MoveScaleImageView alloc]initWithFrame:CANVAS_OPEN_FRAME];
    self.scaleView.displayerDelegate_ = self;
    self.scaleView.drawerDelegate_ = [QueueHandler SharedQueueHandler];
    self.scaleView.dataSource_ = [BoardModel SharedBoard];

//    UIImage* image=[UIImage imageNamed:@"background.jpg"];
    
//    [self.canvas_ initViewWithFrame:CANVAS_OPEN_FRAME withImage:image.CGImage];
//    
//    [self.view addSubview:self.canvas_.scaleImageView];
//    self.canvas_.scaleImageView.drawable = true;
    
    [self.view setUserInteractionEnabled:YES];
    [self.view setMultipleTouchEnabled:YES];
    
    // menu
    self.menuVC_ = [[MenuViewController alloc] init];
    self.menuVC_.moveScaleDelegate_ = self;

    // user list
    self.userListVC_ = [[UserListViewController alloc] init];
    
    // snapshot list
    self.snapshotListVC_ = [[SnapshotListViewController alloc] init];
    self.snapshotListVC_.refreshSnapshotDelegate_ = self;
    [self.view addSubview:self.menuVC_.view];
    [self.view addSubview:self.userListVC_.view];
    [self.view addSubview:self.snapshotListVC_.view];
    
    self.moveBtn_ = [[UIButton alloc] initWithFrame:MOVE_BTN_FRAME];
    [self.moveBtn_ setBackgroundImage:[UIImage imageNamed:@"move.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.moveBtn_];
    [self.moveBtn_ addTarget:self action:@selector(moveBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.biggerBtn_ = [[UIButton alloc] initWithFrame:IncreaseScale_BTN_FRAME];
    [self.biggerBtn_ setBackgroundImage:[UIImage imageNamed:@"bigger.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.biggerBtn_];
    [self.biggerBtn_ addTarget:self action:@selector(biggerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.smallerBtn_ = [[UIButton alloc] initWithFrame:DecreaseScale_BTN_FRAME];
    [self.smallerBtn_ setBackgroundImage:[UIImage imageNamed:@"smaller.png"] forState:UIControlStateNormal];
    [self.view addSubview:self.smallerBtn_];
    [self.smallerBtn_ addTarget:self action:@selector(smallerBtnPress:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (bool)switchDrawMethods{
    self.isHost=!self.isHost;
    return self.isHost;
}

#pragma mark - delegate
- (void)closeDraw {
    self.isHost = false;
}

- (void)setMovable {
    if ([[BoardModel SharedBoard] inHostMode_]&&self.scaleView.isDrawable_) {
        self.scaleView.isDrawable_ = NO;
        SUCCESS_HUD(@"可以缩放拖拽了");
    } else if ([[BoardModel SharedBoard] inHostMode_]&&!self.scaleView.isDrawable_) {
        self.scaleView.isDrawable_ = YES;
        SUCCESS_HUD(@"现在可以画画了");
    }
}

- (void)setStartDraw {
    if ([[BoardModel SharedBoard] inHostMode_]&&!self.scaleView.isDrawable_) {
        self.scaleView.isDrawable_ = YES;
        SUCCESS_HUD(@"现在可以画画了");
    }
}

- (void)scaleSmaller {
    int tmpBoardIndex = [self.scaleView getBoardIndex];
//    NSLog(@"0: %d", tmpBoardIndex);
    if (0==tmpBoardIndex) {
        SUCCESS_HUD(MIN_HINT);
    } else {
        [self.scaleView setScale:(tmpBoardIndex-1)];
    }
}

- (void)scaleBigger {
    int tmpBoardIndex = [self.scaleView getBoardIndex];
//    NSLog(@"0: %d", tmpBoardIndex);
    if (4==tmpBoardIndex) {
        SUCCESS_HUD(MAX_HINT);
    } else {
        [self.scaleView setScale:(tmpBoardIndex+1)];
//        NSLog(@"02 scale: %f", tmpScale);
    }
}

- (void)alert
{
    ERROR_HUD(NETWORK_ERROR);
}

- (void)hint:(NSString *)hintInfo
{
    SUCCESS_HUD(hintInfo);
}

- (void)setCanvasImage:(CGImageRef)imageRef
{
    [self.scaleView setImage:imageRef];
}

- (void)displayerWillRefresh:(id<DisplayerDataSource>) dataSouce_
{
    
    CGImageRef image = [[BoardModel SharedBoard] getData:self.boardIndex];
//    NSLog(@"start to refresh canvas.");
//    [self refreshCurrentSnapshotBtn];
    [self.scaleView setImage:image];

//    NSString *aPath=[NSString stringWithFormat:@"/Users/xujack/%@.jpg",@"test"];
//    NSData *imgData = UIImageJPEGRepresentation([UIImage imageWithCGImage:image],0);
//    [imgData writeToFile:aPath atomically:YES];
    
    CGImageRelease(image);

}

- (void)refreshCurrentSnapshotBtn
{
    CGImageRef image = [[BoardModel SharedBoard] getLatestSnapshot:self.boardIndex];
    [self.snapshotListVC_.snapshotCurrentBtn_ setBackgroundImage:[UIImage imageWithCGImage:image] forState:UIControlStateNormal];
    CGImageRelease(image);
}

- (void)scaleDisplayer:(float)scale
{
    [self.scaleView scaleTo:scale];
}

- (void)moveDisplayerX:(int) x withY:(int)y
{
}

- (bool)startMeeting:(NSString *)meetingCode withUserName:(NSString *)userName
{
    [[BoardModel SharedBoard]attachCanvas:self.scaleView];
     self.opQ_ = [[OwbClientOperationQueue alloc] init];
    [[QueueHandler SharedQueueHandler] setMeetingCode:meetingCode];
    [[QueueHandler SharedQueueHandler] attachQueue:self.opQ_];
    [[BoardModel SharedBoard] attachOpeartionQueue:self.opQ_];
    bool result = [self setBoardLatedDoc:meetingCode withTriedTimes:0];
    [HBController SharedHBController].hbDelegate_ = self;
    [[HBController SharedHBController] hearHBWithUserName:userName withMeetingCode:meetingCode];
    return result;
    
//    self.scaleView.drawable = true;
    //    self.scaleView.drawable = [[BoardModel SharedBoard] inHostMode_];
}

- (bool) setBoardLatedDoc:(NSString *)meetingCode withTriedTimes:(int)times
{
    BOOL _return = NO;
    try {
        OwbClientDocument *latestSnapshot = [[OwbClientServerDelegate sharedServerDelegate] getLatestDocument:meetingCode];
//        NSLog(@"latest snapshot: %d", latestSnapshot.serialNumber_);
        [[QueueHandler SharedQueueHandler]setLatestSeriaNumber:latestSnapshot.serialNumber_];
        [[BoardModel SharedBoard] loadDocumentSync:latestSnapshot];
        [self.userListVC_ setUserList:[[OwbClientServerDelegate sharedServerDelegate] getCurrentUserList:meetingCode]];
//        NSLog(@"meeting id first: %@", meetingCode);
        [self.userListVC_ setMeetingID:meetingCode];
        [self.snapshotListVC_ setMeetingID:meetingCode];
        [self.view addSubview:self.scaleView];
        [self.view sendSubviewToBack:self.scaleView];
//        [self.scaleView display];
        _return = YES;
    } catch (std::exception e) {
        if (times>=MAX_TIMES) {
            [[HBController SharedHBController] stopHear];
            return NO;
        }
        _return = [self setBoardLatedDoc:meetingCode withTriedTimes:++times];
    }
    return _return;
}

- (void)moveBtnPress:(id)sender
{
    [self setMovable];
}

- (void)biggerBtnPress:(id)sender
{
    [self scaleBigger];
}

- (void)smallerBtnPress:(id)sender
{
    [self scaleSmaller];
}
@end
