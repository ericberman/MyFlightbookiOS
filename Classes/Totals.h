/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017-2023 MyFlightbook, LLC
 
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
//  Totals.h
//  MFBSample
//
//  Created by Eric Berman on 12/22/09.
//

#import <UIKit/UIKit.h>
#import "MFBAppDelegate.h"
#import "MFBWebServiceSvc.h"
#import "PullRefreshTableViewController.h"
#import "FlightQueryForm.h"

@interface Totals : PullRefreshTableViewController <MFBSoapCallDelegate, QueryDelegate> {
}

@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * fq;
@end
