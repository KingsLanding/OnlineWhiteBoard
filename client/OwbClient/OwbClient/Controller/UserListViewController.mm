//
//  UserListViewController.m
//  OwbClient
//
//  Created by Jack on 21/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "UserListViewController.h"

@interface UserListViewController ()
@property(nonatomic, strong) UITableView *userTable_;
@end

@implementation UserListViewController

- (id)init
{
    if (self) {
        ul_ = [[OwbClientUserList alloc] init];
        self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userList.png"]];
        self.view.frame = USER_LIST_FRAME;
        UIPanGestureRecognizer *userListGestureRecognizer = [[UIPanGestureRecognizer alloc]
                                                             initWithTarget:self  
                                                             action:@selector(handleUserListPan:)];
        [self.view setUserInteractionEnabled:YES];
        [self.view addGestureRecognizer:userListGestureRecognizer];
        self.userTable_ = [[UITableView alloc] initWithFrame:USER_TABLE_FRAME style:UITableViewStyleGrouped];
        self.userTable_.backgroundColor = [UIColor clearColor];
        self.userTable_.delegate = self;
        self.userTable_.dataSource = self;
//        [self.userTable_ addPullToRefreshWithActionHandler:^{
//            // prepend data to dataSource, insert cells at top of table view
//            // call [tableView.pullToRefreshView stopAnimating] when done
//            [self.userTable_ reloadData];
//            [self.userTable_.pullToRefreshView stopAnimating];
//        }];
        [self.view addSubview:self.userTable_];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

# pragma mark - guesture handler
- (void) handleUserListPan:(UIPanGestureRecognizer*) recognizer
{
//    NSLog(@"meeting id later: %@", mCode_);
    if( ([recognizer state] == UIGestureRecognizerStateBegan) ||
       ([recognizer state] == UIGestureRecognizerStateChanged) )
    {
        CGPoint movement = [recognizer translationInView:self.view];
        CGRect oldRect = self.view.frame;
        
        oldRect.origin.x = oldRect.origin.x + movement.x;
        if(oldRect.origin.x > USER_LIST_OPEN_FRAME.origin.x)
        {
            self.view.frame = USER_LIST_OPEN_FRAME;
        }
        else if(oldRect.origin.x < USER_LIST_CLOSE_FRAME.origin.x)
        {
            self.view.frame = USER_LIST_CLOSE_FRAME;
        }
        else
        {
            self.view.frame = oldRect;
        }
        
        [recognizer setTranslation:CGPointZero inView:self.view];
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat halfPoint = (USER_LIST_CLOSE_FRAME.origin.x + USER_LIST_OPEN_FRAME.origin.x)/ 2;
        if(self.view.frame.origin.x < halfPoint)
        {
            [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.view.frame = USER_LIST_CLOSE_FRAME;
            } completion:^(BOOL finished) {
            }];
        }
        else
        {
            [UIView animateWithDuration:DURATION delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.view.frame = USER_LIST_OPEN_FRAME;
            } completion:^(BOOL finished) {
                [self reload];
            }];
        }
    }
}

- (void)setUserList:(OwbClientUserList *)list
{
    ul_ = list;
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
    return [ul_.userList_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
         
        [cell.textLabel setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        OwbClientUser *tmpUsr= [ul_.userList_ objectAtIndex:indexPath.row];
        cell.textLabel.text = tmpUsr.userName_;
        if (OwbHOST==tmpUsr.identity_) {
            NSLog(@"red: %@", tmpUsr.userName_);
            cell.textLabel.textColor = [UIColor redColor];
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return USER_CELL_HEIGHT;
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
    HeaderLabel.text = USER_HEADER_LABEL;
    [headerView addSubview:HeaderLabel];    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    OwbClientUser *tmpUsr= [ul_.userList_ objectAtIndex:indexPath.row];
    int state = [[OwbClientServerDelegate sharedServerDelegate] transferAuth:tmpUsr.userName_ WithMeetingId:mCode_];
    if (TRANS_SUC==state) {
        [self closeHost];
    } else if (TRANS_UNSURE==state){
        ERROR_HUD(@"该用户可能假死，未能切换成功！");
    } else {
        ERROR_HUD(NETWORK_ERROR);
    }
    [self reload];
}

- (void)closeHost
{
    [self.setDrawableDelegate_ closeDraw];
}

- (void)reload
{
    NSLog(@"-----host------%d", [[BoardModel SharedBoard] inHostMode_]);
    [self.userTable_ setUserInteractionEnabled:[[BoardModel SharedBoard] inHostMode_]];
    TRY(ul_ = [[OwbClientServerDelegate sharedServerDelegate] getCurrentUserList:mCode_]);
    self.userTable_.dataSource = self;
    [self.userTable_ reloadData];
}
@end
