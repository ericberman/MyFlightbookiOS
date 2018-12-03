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
//  TodayTotalsController.m
//  MyFlightbook Currency Today
//
//  Created by Eric Berman on 11/28/18.
//

#import "TodayTotalsController.h"
#import "TotalsRow.h"
#import <NotificationCenter/NotificationCenter.h>

@implementation TodayTotalsController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) callOnBinding:(MFBWebServiceSoapBinding *) binding{
    MFBWebServiceSvc_TotalsForUserWithQuery * totalsForUser = [MFBWebServiceSvc_TotalsForUserWithQuery new];
    totalsForUser.szAuthToken = self.szAuthToken;
    totalsForUser.fq = nil;
    [binding TotalsForUserWithQueryAsyncUsingParameters:totalsForUser delegate:self];
}

- (void) dataReceived:(NSObject *) body {
    if ([body isKindOfClass:[MFBWebServiceSvc_TotalsForUserWithQueryResponse class]]) {
        MFBWebServiceSvc_TotalsForUserWithQueryResponse * resp = (MFBWebServiceSvc_TotalsForUserWithQueryResponse *) body;
        MFBWebServiceSvc_ArrayOfTotalsItem * rgti = resp.TotalsForUserWithQueryResult;
        self.rgData = rgti.TotalsItem;
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
    } else if ([obj isKindOfClass:[MFBWebServiceSvc_TotalsItem class]]) {
        MFBWebServiceSvc_TotalsItem * ti = (MFBWebServiceSvc_TotalsItem *) obj;
        UITableViewCell * cell =  [TotalsRow rowForTotal:ti forTableView:tableView usngHHMM:self.fUseHHMM];
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    
    // should never be here!
    return [tableView dequeueReusableCellWithIdentifier:cellText];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.extensionContext openURL:[NSURL URLWithString:@"myflightbook://totals"] completionHandler:nil];
}

@end
