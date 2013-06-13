//
//  MeetingCodeViewController.m
//  OwbClient
//
//  Created by Jack on 12/4/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "MeetingCodeViewController.h"
#import <Foundation/Foundation.h>

@interface MeetingCodeViewController ()
@property  (nonatomic,strong) NSString *btnLabelStr_;
@end

@implementation MeetingCodeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.scrollEnabled = NO;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style withType:(NSString *)type
{
    self = [self initWithStyle:style];
    self.btnLabelStr_ = type;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.frame = LOGIN_VIEW_FRAME;
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UITextField *textField = [[UITextField alloc]initWithFrame:MEETING_CODE_FRAME];
    [textField setBorderStyle:UITextBorderStyleNone];
    textField.returnKeyType = UIReturnKeyDone;
    textField.delegate = self;
    
    UIButton *codeBtn = [[UIButton alloc] initWithFrame:MEETING_CODE_BTN_FRAME];
    [codeBtn setBackgroundColor:[UIColor clearColor]];
    
    if ([self.btnLabelStr_ isEqual:CREATE_BTN_STR]) {
        [codeBtn setBackgroundImage:[UIImage imageNamed:@"copyBtn.png"] forState:UIControlStateNormal];
        [textField setUserInteractionEnabled:NO];
        [codeBtn addTarget:self action:@selector(createBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        textField.placeholder = self.meetingCode_;
    } else {
        [codeBtn setBackgroundImage:[UIImage imageNamed:@"joinBtn.png"] forState:UIControlStateNormal];
        [textField addTarget:self action:@selector(textFieldWithText:) forControlEvents:UIControlEventEditingChanged];
        [codeBtn addTarget:self action:@selector(joinBtnPress:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    [cell.contentView addSubview:textField];
    [cell.contentView addSubview:codeBtn];
    
    return cell;
}

- (void)createBtnPress:(id)sender
{
    [UIPasteboard generalPasteboard].string = self.meetingCode_;
    SUCCESS_HUD(PASTE_SUC);
}

- (void)joinBtnPress:(id)sender
{
    if (nil==self.meetingCode_) {
        ERROR_HUD(@"请输入会议密钥！");
    } else {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        OwbClientJoinMeetingReturn *joinReturn;
//        NSLog(@"username: %@ \n meetingID:%@", user_.userName_, self.meetingCode_);
        TRY(joinReturn = [[OwbClientServerDelegate sharedServerDelegate] joinMeeting:user_.userName_ WithMeetingId:self.meetingCode_]);
        if (OwbSUCCESS==joinReturn.joinState_) {
            [self.meetingCodeDelegate_ showCanvas:self.meetingCode_ ];
//            NSLog(@"updater ip: %@, port:%d", joinReturn.serverIp_, joinReturn.port_);
            [[OwbClientServerDelegate sharedServerDelegate] bindUpdaterIp:joinReturn.serverIp_ AndPort:joinReturn.port_];
        } else if(OwbFAIL == joinReturn.joinState_) {
            
        } else if(OwbNOTAVAILABLE == joinReturn.joinState_) {
            
        } else if(OwbDEAD == joinReturn.joinState_) {
            
        }
               
    }
}

- (void)setUser:(OwbClientUser *)u
{
    user_ = u;
}

- (void)textFieldWithText:(UITextField *)textField
{
    self.meetingCode_ = [textField text];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
