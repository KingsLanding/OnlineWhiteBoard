//
//  SnapshotListViewController.m
//  OwbClient
//
//  Created by Jack on 21/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "SnapshotListViewController.h"

@interface SnapshotListViewController ()
@property CGImageRef currentSnapshot_;
@property(nonatomic, strong) UITableView *snapshotHistoryTable_;
@property(nonatomic, strong) UIButton *saveSnapshotBtn_;
@end

@implementation SnapshotListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self) {
        self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snapShot.png"]];
        self.view.frame = SNAP_LIST_FRAME;
        UIPanGestureRecognizer *snapListGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                             initWithTarget:self  
                                                             action:@selector(handleSnapListPan:)];
        [self.view setUserInteractionEnabled:YES];
        [self.view addGestureRecognizer:snapListGestureRecognizer];
        self.snapshotHistoryTable_.backgroundColor = [UIColor clearColor];
        self.snapshotCurrentBtn_ = [[UIButton alloc] initWithFrame:SNAP_CUR_BTN_FRAME];
        [self.snapshotCurrentBtn_ setBackgroundColor:[UIColor grayColor]];
        [self.snapshotCurrentBtn_ addTarget:self action:@selector(currentSnapBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.snapshotCurrentBtn_];
        
        self.snapshotHistoryTable_ = [[UITableView alloc] initWithFrame:SNAP_HIS_TABLE_FRAME style:UITableViewStyleGrouped];
        self.snapshotHistoryTable_.backgroundColor = [UIColor clearColor];
        self.snapshotHistoryTable_.delegate = self;
        self.snapshotHistoryTable_.dataSource = self;
        [self.view addSubview:self.snapshotHistoryTable_];
        dl_ = [[OwbClientDocumentList alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

# pragma mark - guesture handler
- (void) handleSnapListPan:(UIPanGestureRecognizer*) recognizer
{
    [self reload];
    if( ([recognizer state] == UIGestureRecognizerStateBegan) ||
       ([recognizer state] == UIGestureRecognizerStateChanged) )
    {
        CGPoint movement = [recognizer translationInView:self.view];
        CGRect oldRect = self.view.frame;
        
        oldRect.origin.x = oldRect.origin.x + movement.x;
        if(oldRect.origin.x < SNAP_LIST_OPEN_FRAME.origin.x)
        {
            self.view.frame = SNAP_LIST_OPEN_FRAME;
        }
        else if(oldRect.origin.x > SNAP_LIST_CLOSE_FRAME.origin.x)
        {
            self.view.frame = SNAP_LIST_CLOSE_FRAME;
        }
        else
        {
            self.view.frame = oldRect;
        }
        
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat halfPoint = (SNAP_LIST_CLOSE_FRAME.origin.x + SNAP_LIST_OPEN_FRAME.origin.x)/ 2;
        if(self.view.frame.origin.x > halfPoint)
        {
            [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.view.frame = SNAP_LIST_CLOSE_FRAME;
            } completion:^(BOOL finished) {
                
            }];
        }
        else
        {
            [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.view.frame = SNAP_LIST_OPEN_FRAME;
            } completion:^(BOOL finished) {
                [self reload];
//                [self.refreshSnapshotDelegate_ refreshCurrentSnapshotBtn];
            }];
        }
    }
}

- (void)reload{
    dl_ = [[OwbClientServerDelegate sharedServerDelegate] getHistorySnapshots:mCode_];
    [self.snapshotHistoryTable_ reloadData];
}

- (void)setMeetingID:(NSString *)meetingCode
{
    mCode_ = meetingCode;
}
#pragma mark - Table view data source and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dl_.documentList_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        OwbClientDocument *tmpDoc = [dl_.documentList_ objectAtIndex:indexPath.row];
        UIImage *tmpImage = [UIImage imageWithData:tmpDoc.data_];
        cell.backgroundView = [[UIImageView alloc] initWithImage:tmpImage];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SNAP_CELL_HEIGHT;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TABLE_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:TABLE_HEADER_FRAME];
    headerView.backgroundColor = [UIColor clearColor];
    UILabel *HeaderLabel = [[UILabel alloc] initWithFrame:TABLE_HEADER_FRAME];
    HeaderLabel.backgroundColor = [UIColor clearColor];
    HeaderLabel.font = [UIFont boldSystemFontOfSize:TABLE_HEADER_FONT_SIZE];
    HeaderLabel.textColor = [UIColor whiteColor];
    HeaderLabel.text = SNAP_HEADER_LABEL;
    [headerView addSubview:HeaderLabel];    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 保存当前画布
    [[BoardModel SharedBoard] saveSnapshot];
    
    currentRow_ = indexPath.row;
    
    if ([[BoardModel SharedBoard] inHostMode_] ) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"查看还是修改？"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:@"修改"
                                                        otherButtonTitles:@"查看", nil];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [actionSheet showFromRect:cell.bounds inView:cell animated:TRUE];
    } else {
        OwbClientDocument *tmpDoc = [dl_.documentList_ objectAtIndex:currentRow_];
        OwbClientDocument *tmpBigDoc = [[OwbClientServerDelegate sharedServerDelegate] getDocument:mCode_ WithSerialNumber:tmpDoc.serialNumber_ ];
        [[BoardModel SharedBoard] loadDocumentAsync:tmpBigDoc];
    }
    [self.refreshSnapshotDelegate_ refreshCurrentSnapshotBtn];
    [self reload];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
	if(buttonIndex != [actionSheet cancelButtonIndex]){
        // 得到完整大图
        OwbClientDocument *tmpDoc = [dl_.documentList_ objectAtIndex:currentRow_];
        OwbClientDocument *tmpBigDoc = [[OwbClientServerDelegate sharedServerDelegate] getDocument:mCode_ WithSerialNumber:tmpDoc.serialNumber_ ];
        [[BoardModel SharedBoard] loadDocumentAsync:tmpBigDoc];
        if (buttonIndex == [actionSheet destructiveButtonIndex]) {
            NSLog(@"set doc --- %d", tmpDoc.serialNumber_);
            [[OwbClientServerDelegate sharedServerDelegate] setDocument:tmpDoc.serialNumber_];
        }
	}
}

#pragma mark - btn handlers
- (void)currentSnapBtnPress:(id)sender
{
    // 载入最新的Docment
    [self.refreshSnapshotDelegate_ setCanvasImage:[[BoardModel SharedBoard] getLatestSnapshot:0]];
}
@end
