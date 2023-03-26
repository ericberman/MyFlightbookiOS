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
//  SignInControllerViewController.m
//  MFBSample
//
//  Created by Eric Berman on 3/16/13.
//
//

#import "SignInControllerViewController.h"
#import "EditCell.h"
#import "ButtonCell.h"
#import "TextCell.h"
#import "NewUserTableController.h"
#import <MyFlightbook-Swift.h>

@interface SignInControllerViewController ()
@property (nonatomic, strong) NSString * szUser;
@property (nonatomic, strong) NSString * szPass;
@property (nonatomic, strong) IBOutlet AccessoryBar * vwAccessory;
@property (nonatomic, strong) NSString * sz2fa;
@end

enum signinSections {sectWhySignIn, sectCredentials, sectSignIn, sectCreateAccount, sectForgotPW, sectLinks, sectAbout, sectPackAndGo, sectLast};
enum signinCellIDs {cidWhySignIn, cidEmail, cidPass, cidSignInOut, cidForgotPW, cidCreateAcct, cidLinksFirst, cidFAQ = cidLinksFirst, cidContact, cidSupport, cidFollowTwitter, cidFollowFB, cidLinksLast=cidFollowFB, cidOptions, cidAbout, cidPackAndGo };

@implementation SignInControllerViewController
@synthesize vwAccessory, szUser, szPass, sz2fa;

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.vwAccessory = [AccessoryBar getAccessoryBar:self];
    
    self.szUser = MFBProfile.sharedProfile.UserName;
    self.szPass = MFBProfile.sharedProfile.Password;
    self.defSectionFooterHeight = self.defSectionHeaderHeight = 5.0;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES];

    self.szUser = MFBProfile.sharedProfile.UserName;
    self.szPass = MFBProfile.sharedProfile.Password;
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Signing In
- (void) showError:(NSString *) msg
{
    [self showErrorAlertWithMessage:msg];
    [self.tableView reloadData];
}

- (void) get2FA {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"2FATitle", @"2fa Title") message:NSLocalizedString(@"2FAPrompt", @"2fa Prompt") preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"2FAWatermark", @"2fa Watermark");
    }];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.sz2fa = alert.textFields[0].text;
        [self.navigationController popViewControllerAnimated:YES];
        [self UpdateProfile];
    }]];
    [self presentViewController:alert animated:YES completion:nil];

}

- (IBAction) UpdateProfile
{
    [self.tableView endEditing:YES];
	
    MFBProfile.sharedProfile.UserName = self.szUser;
    MFBProfile.sharedProfile.Password = self.szPass;
    MFBProfile.sharedProfile.AuthToken = @"";
	
	[MFBProfile.sharedProfile clearCache];
	
    [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"Signing in...", @"Progress: Signing In") onViewController:self];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MFBWebServiceSvc_AuthStatus result = [MFBProfile.sharedProfile GetAuthToken:self.sz2fa];
        
        // if successful, refresh flight properties.
        if (result == MFBWebServiceSvc_AuthStatus_Success) {
            FlightProps * fp = [FlightProps new];
            [fp setCacheRetry];
            [fp loadCustomPropertyTypes];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:^{
                if (result == MFBWebServiceSvc_AuthStatus_Success) {
                    MFBAppDelegate * app = MFBAppDelegate.threadSafeAppDelegate;
                    self.sz2fa = nil;
                    
                    [app ensureWarningShownForUser];
                    [MFBProfile.sharedProfile SavePrefs];
                    [self.tableView reloadData];
                    
                    [[Aircraft sharedAircraft] refreshIfNeeded];
                    
                    [app DefaultPage];
                } else if (result == MFBWebServiceSvc_AuthStatus_TwoFactorCodeRequired) {
                    [self get2FA];
                }
                else
                    [self showError:MFBProfile.sharedProfile.ErrorString];
            }];
        });
    });
}

- (IBAction) signOut:(id)sender
{
    MFBProfile.sharedProfile.UserName = MFBProfile.sharedProfile.Password = MFBProfile.sharedProfile.AuthToken = self.szPass = self.szUser = @"";
    [MFBProfile.sharedProfile clearCache];
    [MFBProfile.sharedProfile clearOldUserContent];
    [MFBProfile.sharedProfile SavePrefs];
    [FlightProps clearTemplates];
    [FlightProps saveTemplates];
    [FlightProps clearAllLocked];
    [PackAndGo clearPackedData];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger) cellIDFromIndexPath:(NSIndexPath *) ip
{
    NSInteger row = ip.row;
    NSInteger section = ip.section;
    
    switch (section)
    {
        case sectWhySignIn:
            return cidWhySignIn;
        case sectCredentials:
            return cidEmail + row;
        case sectSignIn:
            return cidSignInOut;
        case sectForgotPW:
            return cidForgotPW;
        case sectCreateAccount:
            return cidCreateAcct;
        case sectLinks:
            return cidLinksFirst + row;
        case sectAbout:
            return cidOptions + row;
        case sectPackAndGo:
            return cidPackAndGo;
        default:
            return 0;
    }
}

- (UITableViewCell *) getCell
{
    static NSString *CellIdentifier = @"CellNormal";

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
    cell.textLabel.font = [UIFont systemFontOfSize:cell.textLabel.font.pointSize];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == sectCredentials) {
        if (MFBProfile.sharedProfile.isValid)
            return [NSString stringWithFormat:NSLocalizedString(@"You are signed in.", @"Prompt if you are signed in."), MFBProfile.sharedProfile.UserName];
        else
            return NSLocalizedString(@"You are not signed in.  Please sign in or create an account.", @"Prompt if you are not signed in.");
    } else if (section == sectPackAndGo && MFBProfile.sharedProfile.isValid)
        return NSLocalizedString(@"PackAndGoDesc", @"Pack and go description");

    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == sectPackAndGo && MFBProfile.sharedProfile.isValid) {
        NSDate * dtPacked = PackAndGo.lastPackDate;
        if (dtPacked == nil)
            return NSLocalizedString(@"PackAndGoStatusNone", @"Pack and go not packed");
        else {
            NSDateFormatter * df = NSDateFormatter.new;
            df.dateStyle = NSDateFormatterShortStyle;
            df.timeStyle = NSDateFormatterLongStyle;
            return [NSString stringWithFormat:NSLocalizedString(@"PackAndGoStatusOK", @"Pack and go status OK"), [df stringFromDate:dtPacked]];
        }
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sectLast;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case sectWhySignIn:
            return MFBProfile.sharedProfile.isValid ? 0 : 1; // just the explanation text
        case sectCredentials:
            return MFBProfile.sharedProfile.isValid ? 0 : 2; // email + password
        case sectSignIn:
            return 1;
        case sectForgotPW:
            return 1; // just the "Forgot password" cell
        case sectPackAndGo:
            return MFBProfile.sharedProfile.isValid ? 1 : 0;
        case sectCreateAccount:
            return MFBProfile.sharedProfile.isValid ? 0 : 1; // just the "Create account" cell, but only if not signed in
        case sectLinks:
            return cidLinksLast - cidLinksFirst + 1;
        case sectAbout:
            return 2; // About cell + options
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cid = [self cellIDFromIndexPath:indexPath];
    
    switch (cid)
    {
        case cidWhySignIn:
        {
            TextCell * tc = [TextCell getTextCellTransparent:self.tableView];
            tc.txt.text = NSLocalizedString(@"Sign-in Header", @"Prompt for signing in");
            return tc;
        }
        case cidAbout:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"About MyFlightbook", @"About MyFlightbook prompt");
            return cell;
        }
        case cidForgotPW:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"Reset Password", @"Reset Password Prompt");
            return cell;
        }
        case cidSignInOut:
        {
            ButtonCell * cell = [ButtonCell getButtonCell:self.tableView];
            if (MFBProfile.sharedProfile.isValid)
            {
                [cell.btn setTitle:NSLocalizedString(@"Sign-out", @"Sign-out") forState:0];
                [cell.btn addTarget:self action:@selector(signOut:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [cell.btn setTitle:NSLocalizedString(@"Sign-in", @"Sign-in") forState:0];
                [cell.btn addTarget:self action:@selector(UpdateProfile) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
        case cidEmail:
        case cidPass:
        {
            EditCell * ec = [EditCell getEditCell:self.tableView withAccessory:self.vwAccessory];
            ec.txt.delegate = self;
            ec.txt.keyboardType = (cid == cidEmail) ? UIKeyboardTypeEmailAddress : UIKeyboardTypeDefault;
            ec.txt.secureTextEntry = (cid == cidPass);
            ec.txt.autocorrectionType = UITextAutocorrectionTypeNo;
            ec.txt.text = (cid == cidEmail) ? self.szUser : self.szPass;
            ec.lbl.text = (cid == cidEmail) ? NSLocalizedString(@"E-mail", @"E-mail prompt") : NSLocalizedString(@"Password", @"PasswordPrmopt");
            ec.txt.placeholder = (cid == cidEmail) ? NSLocalizedString(@"E-Mail Placeholder", @"E-Mail Placeholder") : NSLocalizedString(@"Password Placeholder", @"Password Placeholder");
            ec.txt.returnKeyType = (cid == cidEmail) ? UIReturnKeyNext : UIReturnKeyGo;
            return ec;
        }
        case cidCreateAcct:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"Create a free Account", @"Create an account prompt");
            return cell;
        }
        case cidFAQ:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"FAQ", @"FAQ prompt");
            cell.imageView.image = [UIImage imageNamed:@"MFBLogo"];;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
        case cidFollowFB:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"Follow on Facebook", @"Prompt to follow on Facebook");
            cell.imageView.image = [UIImage imageNamed:@"f_logo"];
            cell.textLabel.textColor = [UILabel appearance].textColor;
            return cell;
        }
        case cidFollowTwitter:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"Follow on Twitter", @"Prompt to follow on Twitter");
            cell.imageView.image = [UIImage imageNamed:@"twitter"];
            cell.textLabel.textColor = [UILabel appearance].textColor;
            return cell;
        }
        case cidSupport:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"SupportPrompt", @"Support");
            cell.imageView.image = [UIImage imageNamed:@"MFBLogo"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.textColor = ([MFBProfile.sharedProfile isValid]) ? [UILabel appearance].textColor : [UIColor grayColor];
            return cell;
        }
        case cidContact:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"Contact Us", @"Contact Us prompt");
            cell.imageView.image = [UIImage imageNamed:@"MFBLogo"];
            return cell;
        }
        case cidOptions:
        {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"Options", @"Options button for autodetect, etc.");
            return cell;
        }
        case cidPackAndGo: {
            UITableViewCell * cell = [self getCell];
            cell.textLabel.text = NSLocalizedString(@"PackAndGo", @"Pack and Go");
            cell.accessoryType = UITableViewCellAccessoryNone;
            return cell;
        }
    }
    
    @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in SignInViewController with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
}

#pragma mark - Table view delegate
- (void) pushURL:(NSString *) szURL
{
    HostedWebViewController * vwWeb = [[HostedWebViewController alloc] initWithUrl:szURL];
	[self.navigationController pushViewController:vwWeb animated:YES];
}

- (void) contactUs
{
	NSString * szURL = [NSString stringWithFormat:@"https://%@/logbook/public/ContactMe.aspx?email=%@&subj=%@&noCap=1&naked=1",
						MFBHOSTNAME,
                        MFBProfile.sharedProfile.UserName,
						[[NSString stringWithFormat:@"Comment from %@ user", (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"iPad" : @"iPhone"] stringByURLEncodingString]];
    [self pushURL:szURL];
}

- (void) followOnFacebook
{
    NSString * szURL = @"https://www.facebook.com/pages/MyFlightbook/145794653106";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:szURL] options:@{} completionHandler:nil];
}

- (void) followOnTwitter
{
    NSString * szURL = @"https://www.twitter.com/myflightbook";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:szURL] options:@{} completionHandler:nil];
}

- (void) showAbout
{
	about * vwAbout = [[about alloc] initWithNibName:@"about" bundle:nil];
    [self.navigationController pushViewController:vwAbout animated:YES];
}

- (void) createUser
{
    NewUserTableController * nutc = [[NewUserTableController alloc] initWithNibName:@"NewUserTableController" bundle:nil];
	[self.navigationController pushViewController:nutc animated:YES];
}

- (BOOL) runBlock:(BOOL (^)(void)) callToMake withMessage:(NSString *) sz onAlert:(UIAlertController *) uac {
    dispatch_async(dispatch_get_main_queue(), ^{ uac.title = sz; });
    return callToMake();
}

- (void) packAndGo {
    [self.tableView endEditing:YES];

    UIAlertController * uac = [WPSAlertController presentProgressAlertWithTitle:NSLocalizedString(@"PackAndGoInProgress", @"Pack and go - downloaded") onViewController:self];
    
    PackAndGo * p = [PackAndGo new];
    p.authToken = MFBProfile.sharedProfile.AuthToken;

    [p packAllWithProgressUpdate:^(NSString * _Nonnull sz) {
        uac.title = sz;
    } completionHandler:^{
        [self dismissViewControllerAnimated:YES completion:^{
            if (p.errorString.length > 0)
                [self showError:p.errorString];
        }];
        [self.tableView reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.ipActive = indexPath;
    NSInteger cid = [self cellIDFromIndexPath:indexPath];
    
    switch (cid)
    {
        case cidForgotPW:
            [self.tableView endEditing:YES];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/logbook/Logon/ResetPass.aspx", MFBHOSTNAME]] options:@{} completionHandler:nil];
            break;
        case cidContact:
            [self.tableView endEditing:YES];
            [self contactUs];
            break;
        case cidFollowFB:
            [self.tableView endEditing:YES];
            [self followOnFacebook];
            break;
        case cidFollowTwitter:
            [self.tableView endEditing:YES];
            [self followOnTwitter];
            break;
        case cidAbout:
            [self.tableView endEditing:YES];
            [self showAbout];
            break;
        case cidFAQ:
            [self.tableView endEditing:YES];
            [self pushURL:[MFBProfile.sharedProfile authRedirForUser:@"d=faq&naked=1"]];
            break;
        case cidSupport:
            [self.tableView endEditing:YES];
            
            if (!MFBProfile.sharedProfile.isValid)
                return;
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[MFBProfile.sharedProfile authRedirForUser:@"d=donate"]] options:@{} completionHandler:nil];
            break;
        case cidCreateAcct:
            [self.tableView endEditing:YES];
            [self createUser];
            break;
        case cidEmail:
        case cidPass:
        {
            EditCell * ec = (EditCell *) [self.tableView cellForRowAtIndexPath:indexPath];
            [ec.txt becomeFirstResponder];
        }
            break;
        case cidOptions:
            [self.navigationController pushViewController:[[AutodetectOptions alloc] initWithNibName:@"AutodetectOptions" bundle:nil] animated:YES];
            break;
        case cidPackAndGo:
            [self packAndGo];
            break;
        default:
            [self.tableView endEditing:YES];
            break;
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate
- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger cid = [self cellIDFromIndexPath:[self.tableView indexPathForCell:[self owningCell:textField]]];
    
    if (cid == cidEmail)
        self.szUser = textField.text;
    else if (cid == cidPass)
        self.szPass = textField.text;
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
    NSInteger cid = [self cellIDFromIndexPath:[self.tableView indexPathForCell:[self owningCell:textField]]];
    if (cid == cidPass)
    {
        [textField resignFirstResponder];
        [self UpdateProfile];
    }
    else
        [self nextClicked];
    return YES;
}

#pragma mark -
#pragma mark AccessoryViewDelegates
- (BOOL) isNavigableRow:(NSIndexPath *)ip
{
    switch ([self cellIDFromIndexPath:ip])
    {
        case cidEmail:
        case cidPass:
            return YES;
        default:
            return NO;
    }
}
@end
