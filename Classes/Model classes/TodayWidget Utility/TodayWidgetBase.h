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
//  TodayWidgetBase.h
//  MyFlightbook
//
//  Created by Eric Berman on 11/29/18.
//

#import <UIKit/UIKit.h>
#import "HostName.h"
#import "MFBWebServiceSvc.h"

@interface TodayWidgetBase : UITableViewController<MFBWebServiceSoapBindingResponseDelegate>
@property (strong, nonatomic) NSMutableArray * rgData;
@property (readwrite, nonatomic) BOOL fUseHHMM;
@property (nonatomic, strong) NSString * szAuthToken;

// Subclasses MUST implement the following:
- (void) callOnBinding:(MFBWebServiceSoapBinding *) binding;
- (void) dataReceived:(NSObject *) body;
// Subclasses also must handle click on table rows.

@end
