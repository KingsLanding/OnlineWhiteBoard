//
//  LoginViewController.m
//  OwbClient
//
//  Created by  tsgsz on 4/8/13.
//  Copyright (c) 2013 tsgsz. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () 
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) UITextField *nameText_;
@property (nonatomic, strong) UITextField *pwdText_;
@end
@implementation LoginViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        self.tableView.scrollEnabled = NO;
        self.labels = @[@"帐号",@"密码"];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    return [self.labels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSInteger row = [indexPath row];
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = row;
        label.highlightedTextColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.opaque = NO;
        label.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:label];
    }
    
    UILabel *label = (UILabel*)[cell viewWithTag:row];
    NSString *title = [self.labels objectAtIndex:indexPath.row];
    CGRect cellFrame = [cell frame];
    cellFrame.origin = CGPointMake(10, 10);
    label.text = title;
    [label setFont:[UIFont fontWithName:@"Helvetica" size:18.0]];
    CGRect rect = CGRectInset(cellFrame,2,2);
    label.frame = rect;
    [label sizeToFit];
    
    if (indexPath.row==1) {
        self.pwdText_=[[UITextField alloc]initWithFrame:LOGIN_INPUT_FRAME];
        self.pwdText_.borderStyle = UITextBorderStyleNone;
        self.pwdText_.backgroundColor = [UIColor clearColor];
        self.pwdText_.returnKeyType = UIReturnKeyJoin;
        self.pwdText_.placeholder = LOGIN_PWD_PLACEHOLDER;
        self.pwdText_.delegate = self;
        self.pwdText_.secureTextEntry = YES;
        [self.pwdText_ addTarget:self action:@selector(pswdEdited:) forControlEvents:UIControlEventEditingChanged];
        [cell.contentView addSubview:self.pwdText_];
    } else {
        self.nameText_=[[UITextField alloc]initWithFrame:LOGIN_INPUT_FRAME];
        self.nameText_.borderStyle = UITextBorderStyleNone;
        self.nameText_.backgroundColor = [UIColor clearColor];
        self.nameText_.returnKeyType = UIReturnKeyNext;
        self.nameText_.placeholder = LOGIN_NAME_PLACEHOLDER;
        self.nameText_.delegate = self;
        [self.nameText_ addTarget:self action:@selector(nameEdited:) forControlEvents:UIControlEventEditingChanged];
        [cell.contentView addSubview:self.nameText_];
    }
    return cell;
}

- (void)nameEdited:(UITextField *)textField
{
    self.userName_ = [textField text];
}

- (void)pswdEdited:(UITextField *)textField
{
    self.userPswd_ = [textField text];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.pwdText_) {
        if (nil==self.userName_||nil==self.userPswd_) {
            ERROR_HUD(CANNOT_NULL);
        } else {
            [self.loginDelegate_ login];
        }
        [theTextField resignFirstResponder];
    } else if (theTextField == self.nameText_) {
        [self.pwdText_ becomeFirstResponder];
    }
    return YES;
}

@end
