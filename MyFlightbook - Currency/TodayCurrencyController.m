/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2018 MyFlightbook, LLC
 
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
//  TodayCurrencyController.m
//  MyFlightbook Currency Today
//
//  Created by Eric Berman on 11/28/18.
//

#import "TodayCurrencyController.h"
#import "CurrencyRow.h"
#import <NotificationCenter/NotificationCenter.h>

@implementation TodayCurrencyController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) callOnBinding:(MFBWebServiceSoapBinding *) binding {
    MFBWebServiceSvc_GetCurrencyForUser * currencyForUserSVC = [MFBWebServiceSvc_GetCurrencyForUser new];
    currencyForUserSVC.szAuthToken = self.szAuthToken;
    [binding GetCurrencyForUserAsyncUsingParameters:currencyForUserSVC delegate:self];
}

- (void) dataReceived:(NSObject *) body {
    if ([body isKindOfClass:[MFBWebServiceSvc_GetCurrencyForUserResponse class]]) {
        MFBWebServiceSvc_GetCurrencyForUserResponse * resp = (MFBWebServiceSvc_GetCurrencyForUserResponse *) body;
        MFBWebServiceSvc_ArrayOfCurrencyStatusItem * rgCs = resp.GetCurrencyForUserResult;
        self.rgData = rgCs.CurrencyStatusItem;
    }
}

#pragma mark - TableViewController

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellText = @"Cell";
    
    NSObject * obj = self.rgData[indexPath.row];
    
    if ([obj isKindOfClass:[NSString class]]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellText];
        if (cell == nil)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellText];
            
        cell.textLabel.text = self.rgData[indexPath.row];
        return cell;
    } else if ([obj isKindOfClass:[MFBWebServiceSvc_CurrencyStatusItem class]]) {
        MFBWebServiceSvc_CurrencyStatusItem * ci = (MFBWebServiceSvc_CurrencyStatusItem *) obj;
        return [CurrencyRow rowForCurrency:ci forTableView:tableView];
    }

    // should never be here!
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.extensionContext openURL:[NSURL URLWithString:@"myflightbook://currency"] completionHandler:nil];
}
@end
