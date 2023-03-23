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
//  AircraftViewControllerBase.m
//  MFBSample
//
//  Created by Eric Berman on 3/12/19.
//
//

#import "AircraftViewController.h"

@implementation AircraftViewControllerBase
@synthesize delegate, rgImages, vwAccessory, imagesSection, ac, progress;

- (instancetype) initWithAircraft:(MFBWebServiceSvc_Aircraft *) aircraft {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.ac = aircraft;
        self.tableView.rowHeight = 44.0;
        self.tableView.sectionHeaderHeight = self.tableView.sectionFooterHeight = 10.0;
    }
    return self;
}

- (void) addImage:(CommentedImage *)ci {
    [self.rgImages addObject:ci];
    [self.tableView reloadData];
    [super addImage:ci];
    if (![self isExpanded:self.imagesSection])
        [self expandSection:self.imagesSection];
}

- (void) imagesComplete:(NSArray *)ar {
    assert(NO); // should always be subclassed
}

- (void) aircraftRefreshComplete:(MFBSoapCall *) sc withCaller:(Aircraft *) a {
    // dismiss the view controller
    [self dismissViewControllerAnimated:YES completion:^{
        // display any error that happened at any point
        if ([sc.errorString length] > 0)
            [self showErrorAlertWithMessage:sc.errorString];
        else {
            // Notify of a change so that the whole list gets refreshed
            [self.delegate aircraftListChanged];
            // the add/update was successful, so we can pop the view.  Don't pop the view if the add/update failed.
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    self.progress = nil;
}

- (void) submitImagesWorker:(NSArray *) ar {
    @autoreleasepool {
        BOOL fIsNew = self.ac.isNew;
        NSString * targetURL = fIsNew ? MFBConstants.MFBAIRCRAFTIMAGEUPLOADPAGENEW : MFBConstants.MFBAIRCRAFTIMAGEUPLOADPAGE;
        NSString * key = fIsNew ? ac.TailNumber : ac.AircraftID.stringValue;
        [CommentedImage uploadImages:self.rgImages progressUpdate:^(NSString * sz) { self.progress.title = sz; }
                              toPage:targetURL authString:MFBProfile.sharedProfile.AuthToken keyName:MFBConstants.MFB_KEYAIRCRAFTIMAGE keyValue:key];
        [self performSelectorOnMainThread:@selector(imagesComplete:) withObject:ar waitUntilDone:NO];
    }
}

- (void) aircraftWorkerComplete:(MFBSoapCall *)sc withCaller:(Aircraft *) a {
    if ([sc.errorString length] == 0)
        [NSThread detachNewThreadSelector:@selector(submitImagesWorker:) toTarget:self withObject:@[sc, a]];
    else
        [self aircraftRefreshComplete:sc withCaller:a];
}

- (void) commitAircraft {
    if (!MFBAppDelegate.threadSafeAppDelegate.isOnLine) {
        MFBSoapCall * sc = MFBSoapCall.new;
        sc.errorString = NSLocalizedString(@"No access to the Internet", @"Error message if app cannot connect to the Internet");
        [self aircraftRefreshComplete:sc withCaller:Aircraft.sharedAircraft];
        return;
    }

    // Don't upload if we have videos and are not on wifi:
    if (![CommentedImage canSubmitImages:self.rgImages]) {
        MFBSoapCall * sc = [MFBSoapCall alloc];
        sc.errorString = NSLocalizedString(@"ErrorNeedWifiForVids", @"Can't upload with videos unless on wifi");
        [self aircraftRefreshComplete:sc withCaller:[Aircraft sharedAircraft]];
        return;
    }
    
    Aircraft * a = [[Aircraft alloc] init];
    [a setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self aircraftWorkerComplete:sc withCaller:(Aircraft *) ao];
    }];
    a.rgAircraftForUser = nil;
    NSString * szAuthToken = MFBProfile.sharedProfile.AuthToken;
    
    if (self.ac.isNew)
        [a addAircraft:self.ac ForUser:szAuthToken];
    else
        [a updateAircraft:self.ac ForUser:szAuthToken];
}
@end
