/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2013-2023 MyFlightbook, LLC
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//  NewUserTableController.m
//  MFBSample
//
//  Created by Eric Berman on 3/17/13.
//
//

#import "NewUserTableController.h"
#import "ButtonCell.h"
#import "TextCell.h"
#import "EditCell.h"
#import "MFBAppDelegate.h"
#import "SecurityQuestionPicker.h"
#import <MyFlightbook-Swift.h>

@interface NewUserTableController ()

@property (nonatomic, strong) AccessoryBar * vwAccessory;
@property (nonatomic, strong) NewUserObject * nuo;

- (void) createUser;
- (void) viewPrivacy;
- (void) viewTAndC;

@end

@implementation NewUserTableController

enum sectNewUser {sectCredentials, sectName, sectQAExplanation, sectQA, sectLegal, sectCreate, sectLast};
enum rowNewUser {rowEmail, rowEmail2, rowPass, rowPass2, rowFirstName, rowLastName, rowQAExplanation1, rowQuestion, rowAnswer,
    rowPrivacy, rowTandC, rowAgree, rowCreate};

@synthesize vwAccessory, nuo;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    self.nuo = [[NewUserObject alloc] init];
	self.navigationItem.title = NSLocalizedString(@"Create Account", @"Title for create account screen");
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger) rowFromIndexPath:(NSIndexPath *) ip;
{
    switch (ip.section)
    {
        case sectCreate:
            return rowAgree + ip.row;
        case sectCredentials:
            return rowEmail + ip.row;
        case sectLegal:
            return rowPrivacy + ip.row;
        case sectName:
            return rowFirstName + ip.row;
        case sectQA:
            return rowQuestion + ip.row;
        case sectQAExplanation:
            return rowQAExplanation1;
        default:
            return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectLast;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case sectCreate:
            return rowCreate - rowAgree + 1;
        case sectCredentials:
            return rowPass2 - rowEmail + 1;
        case sectLegal:
            return rowTandC - rowPrivacy + 1;
        case sectName:
            return rowLastName - rowFirstName + 1;
        case sectQA:
            return rowAnswer - rowQuestion + 1;
        case sectQAExplanation:
            return 1;
        default:
            return 0;
    }
}

- (NSString *) QARationaleString
{
    return NSLocalizedString(@"For password recovery, please provide a question and answer.", @"Question/Answer Rationale 1");
}

- (CGFloat) QARationaleHeight
{
    CGFloat h = [[self QARationaleString] boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 20, 10000)
                                 options:NSStringDrawingUsesLineFragmentOrigin
                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0]}
                                 context:nil].size.height;
    return ceil(h) + 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self rowFromIndexPath:indexPath] == rowQAExplanation1)
    return [self QARationaleHeight];
    
    return UITableViewAutomaticDimension;
}

- getCell:(UITableView *)tv
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self rowFromIndexPath:indexPath];

    UITableViewCell * cell = nil;
    ButtonCell * bc;
    TextCell * tc;
    EditCell * ec;
    
    switch (row)
    {
        case rowAgree:
            cell = tc = [TextCell getTextCellTransparent:tableView];
            tc.txt.text = NSLocalizedString(@"By creating an account, you are agreeing to the terms and conditions.", @"Terms and Conditions agreement");
            break;
        case rowQuestion:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            ec.txt.placeholder = NSLocalizedString(@"Question Placeholder", @"Question Placeholder");
            [ec setLabelToFit:NSLocalizedString(@"Secret Question", @"Secret Question Prompt")];
            ec.txt.text = self.nuo.szQuestion;
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.delegate = self;
            ec.txt.adjustsFontSizeToFitWidth = YES;
            ec.accessoryType = UITableViewCellAccessoryDetailButton;
            break;
        case rowAnswer:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            ec.txt.placeholder = NSLocalizedString(@"Answer Placeholder", @"Answer Placeholder");
            [ec setLabelToFit:NSLocalizedString(@"Secret Answer", @"Secret Answer Prompt")];
            ec.lbl.adjustsFontSizeToFitWidth = YES;
            ec.txt.text = self.nuo.szAnswer;
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.delegate = self;
            ec.txt.adjustsFontSizeToFitWidth = YES;
            break;
        case rowEmail:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            [ec setLabelToFit:NSLocalizedString(@"E-mail", @"E-mail Prompt")];
            ec.txt.placeholder = NSLocalizedString(@"E-Mail Placeholder", @"E-Mail Placeholder");
            ec.txt.text = self.nuo.szEmail;
            ec.txt.keyboardType = UIKeyboardTypeEmailAddress;
            ec.txt.autocorrectionType = UITextAutocorrectionTypeNo;
            ec.txt.delegate = self;
            break;
        case rowEmail2:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            [ec setLabelToFit:NSLocalizedString(@"Confirm E-mail", @"Confirm E-mail")];
            ec.txt.placeholder = NSLocalizedString(@"E-Mail Placeholder", @"E-Mail Placeholder");
            ec.txt.text = self.nuo.szEmail2;
            ec.txt.keyboardType = UIKeyboardTypeEmailAddress;
            ec.txt.autocorrectionType = UITextAutocorrectionTypeNo;
            ec.txt.delegate = self;
            break;
        case rowPass:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            [ec setLabelToFit:NSLocalizedString(@"Password", @"Password prompt")];
            ec.txt.placeholder = NSLocalizedString(@"Password Placeholder", @"Password Placeholder");
            ec.txt.text = self.nuo.szPass;
            ec.txt.secureTextEntry = YES;
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.delegate = self;
            break;
        case rowPass2:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            ec.txt.placeholder = NSLocalizedString(@"Password Placeholder", @"Password Placeholder");
            [ec setLabelToFit:NSLocalizedString(@"Confirm Password", @"Confirm Password prompt")];
            ec.txt.text = self.nuo.szPass2;
            ec.txt.secureTextEntry = YES;
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.delegate = self;
            break;
        case rowFirstName:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            ec.lbl.text = NSLocalizedString(@"First Name", @"First Name prompt");
            ec.txt.placeholder = NSLocalizedString(@"(Optional)", @"Optional");
            ec.txt.text = self.nuo.szFirst;
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.delegate = self;
            break;
        case rowLastName:
            cell = ec = [EditCell getEditCell:tableView withAccessory:self.vwAccessory];
            ec.lbl.text = NSLocalizedString(@"Last Name", @"Last Name prompt");
            ec.txt.text = self.nuo.szLast;
            ec.txt.placeholder = NSLocalizedString(@"(Optional)", @"Optional");
            ec.txt.keyboardType = UIKeyboardTypeDefault;
            ec.txt.delegate = self;
            break;
        case rowCreate:
            cell = bc = [ButtonCell getButtonCell:tableView];
            [bc.btn setTitle:NSLocalizedString(@"Create Account", @"Create Account button") forState:0];
            [bc.btn addTarget:self action:@selector(createUser) forControlEvents:UIControlEventTouchUpInside];
            break;
        case rowPrivacy:
            cell = [self getCell:tableView];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"View Privacy Policy", @"View Privacy Policy prompt");
            break;
        case rowTandC:
            cell = [self getCell:tableView];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = NSLocalizedString(@"View Terms and Conditions", @"View Terms and Conditions prompt");
            break;
        case rowQAExplanation1:
            cell = tc = [TextCell getTextCellTransparent:tableView];
            tc.txt.text = NSLocalizedString(@"For password recovery, please provide a question and answer.", @"Question/Answer Rationale 1");
            tc.txt.numberOfLines = 20;
            tc.txt.font = [UIFont systemFontOfSize:12];
            tc.txt.adjustsFontSizeToFitWidth = NO;
            break;
        default:
            @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in NewUserTableController with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
            break;
    }

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [self rowFromIndexPath:indexPath];
    
    switch (row)
    {
        case rowPrivacy:
            [self.tableView endEditing:YES];
            [self viewPrivacy];
            break;
        case rowTandC:
            [self.tableView endEditing:YES];
            [self viewTAndC];
            break;
        case rowEmail:
        case rowEmail2:
        case rowPass:
        case rowPass2:
        case rowFirstName:
        case rowLastName:
        case rowQuestion:
        case rowAnswer:
            [((EditCell *) [self.tableView cellForRowAtIndexPath:indexPath]).txt becomeFirstResponder];
            break;
        default:
            [self.tableView endEditing:YES];
            break;
    }
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if ([self rowFromIndexPath:indexPath] == rowQuestion)
    {
        SecurityQuestionPicker * sqp = [SecurityQuestionPicker new];
        sqp.nuo = self.nuo;
        [self.navigationController pushViewController:sqp animated:YES];
    }
}

#pragma mark - Create User
- (void) createUserFinishedFailure {
    [self showErrorAlertWithMessage:mfbApp().userProfile.ErrorString];
}

- (void) createUserFinishedSuccess
{
	MFBAppDelegate * app = mfbApp();
    
    // cache the relevant credentials, load any aircraft, and go to the default page for the user!
    [app.userProfile SavePrefs];
    [[Aircraft sharedAircraft] refreshIfNeeded];
    
    // Refresh properties on a background thread.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[FlightProps new] loadCustomPropertyTypes];
    });
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Welcome to MyFlightbook!", @"New user welcome message title") message:NSLocalizedString(@"\r\nBefore you can enter flights, you must set up at least one aircraft that you fly.", @"New user 'Next steps' message") preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"Close button on error message") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) createUserWorker
{
    @autoreleasepool {
        MFBAppDelegate * app = [MFBAppDelegate threadSafeAppDelegate];
        BOOL fSuccess = [app.userProfile createUser:self.nuo] && [app.userProfile isValid];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                if (fSuccess)
                    [self createUserFinishedSuccess];
                else
                    [self createUserFinishedFailure];
            }];
        });
    }
}

- (void) createUser
{
    // Pick up any pending changes
    [self.view endEditing:YES];
    
    if (![self.nuo isValid])
	{
        [self showErrorAlertWithMessage:self.nuo.szLastError];
		return;
	}
	
    [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"Creating Account...", @"Progress indicator") onViewController:self];
    
	[NSThread detachNewThreadSelector:@selector(createUserWorker) toTarget:self withObject:nil];
}

- (void) viewPrivacy
{
    HostedWebViewController * vwWeb = [[HostedWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"https://%@/logbook/public/privacy.aspx?naked=1", MFBHOSTNAME]];
	[self.navigationController pushViewController:vwWeb animated:YES];
}

- (void) viewTAndC
{
    HostedWebViewController * vwWeb = [[HostedWebViewController alloc] initWithUrl:[NSString stringWithFormat:@"https://%@/logbook/Public/TandC.aspx?naked=1", MFBHOSTNAME]];
	[self.navigationController pushViewController:vwWeb animated:YES];
}

#pragma mark UITextFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger row = [self rowFromIndexPath:[self.tableView indexPathForCell:[self owningCell:textField]]];
    NSString * sz = textField.text;
    switch (row)
    {
        case rowEmail:
            self.nuo.szEmail = sz;
            break;
        case rowEmail2:
            self.nuo.szEmail2 = sz;
            break;
        case rowPass:
            self.nuo.szPass = sz;
            break;
        case rowPass2:
            self.nuo.szPass2 = sz;
            break;
        case rowFirstName:
            self.nuo.szFirst = sz;
            break;
        case rowLastName:
            self.nuo.szLast = sz;
            break;
        case rowQuestion:
            self.nuo.szQuestion = sz;
            break;
        case rowAnswer:
            self.nuo.szAnswer = sz;
            break;
    }
}

- (BOOL) textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    self.ipActive = [self.tableView indexPathForCell:[self owningCell:textField]];
    [self enableNextPrev:self.vwAccessory];
    
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self.tableView endEditing:YES];
    return YES;
}

#pragma mark - AccessoryViewDelegates
- (BOOL) isNavigableRow:(NSIndexPath *)ip
{
    switch ([self rowFromIndexPath:ip])
    {
        case rowEmail:
        case rowEmail2:
        case rowPass:
        case rowPass2:
        case rowFirstName:
        case rowLastName:
        case rowQuestion:
        case rowAnswer:
            return YES;
        default:
            return NO;
    }
}
@end
