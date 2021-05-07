/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2018-2021 MyFlightbook, LLC
 
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
//  TodayWidgetBase.m
//  MyFlightbook
//
//  Created by Eric Berman on 11/29/18.
//


#import "TodayWidgetBase.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayWidgetBase () <NCWidgetProviding>
@property (nonatomic, copy) void (^onUpdate)(NCUpdateResult);
@end

@implementation TodayWidgetBase

@synthesize rgData, fUseHHMM, onUpdate, szAuthToken;

- (void) callOnBinding:(MFBWebServiceSoapBinding *) binding{
    // MUST BE HANDLED IN SUBCLASS
}

- (void) dataReceived:(NSObject *) body {
    // MUST BE HANDLED IN SUBCLASS
}


- (CGSize) compactSize {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    return CGSizeMake(self.view.frame.size.width, cell.frame.size.height);
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.rgData = [[NSMutableArray alloc] init];
    self.szAuthToken = nil;
    self.extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayModeExpanded;
    
    self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    
    if (self.extensionContext.widgetActiveDisplayMode == NCWidgetDisplayModeCompact)
        self.preferredContentSize = self.compactSize;
}

- (void) makeCall {
    MFBWebServiceSoapBinding * binding = [MFBWebServiceSvc MFBWebServiceSoapBinding];
    
    if (binding.timeout < 30)
        binding.timeout = 30; // at least 30 seconds for a timeout.
    
    // request the correct language/locale
    NSString * szPreferredLocale = [[NSLocale currentLocale] localeIdentifier];
    NSString * szPreferredLanguage = [NSLocale preferredLanguages][0];
    
    NSArray * rgElem = [szPreferredLocale componentsSeparatedByString:@"_"];
    
    if ([rgElem count] >= 2)
    {
        NSString * szAcceptsHeader = [NSString stringWithFormat:@"%@-%@", szPreferredLanguage, rgElem[1]];
        [binding.customHeaders setValue:szAcceptsHeader forKey:@"Accept-Language"];
    }
    
    NSURL *testAddress = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://%@/logbook/public/WebService.asmx", MFBHOSTNAME]];
    binding.address = testAddress;
    
    if (binding != nil)
        [self callOnBinding:binding];
}

- (void)operation:(MFBWebServiceSoapBindingOperation *)operation completedWithResponse:(MFBWebServiceSoapBindingResponse *)response {
    if (response != nil && [[response.error localizedDescription] length] > 0)
        self.rgData = [NSMutableArray arrayWithObject:response.error.localizedDescription];
    else {
        NSArray * responseBodyParts = response.bodyParts;
        
        for (id bodyPart in responseBodyParts)
        {
            if ([bodyPart isKindOfClass:[SOAPFault class]])
            {
                SOAPFault * sf = (SOAPFault *) bodyPart;
                // strip off the preamble, if present, which is: "Server was unable to process request. --->"
                NSRange ns = [sf.faultstring rangeOfString:@"-->"];
                if (ns.location != NSNotFound)
                    self.rgData = [NSMutableArray arrayWithObject:[sf.faultstring substringFromIndex:(ns.location+ ns.length)]];
                else
                    self.rgData = [NSMutableArray arrayWithObject:sf.faultstring];
            }
            else
                [self dataReceived:bodyPart];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    self.onUpdate(NCUpdateResultNewData);
}

#pragma mark - Widget Handler
- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSString * const _szKeyCachedToken = @"keyCacheAuthToken";
    NSString * const _szKeyHHMM = @"keyUseHHMM";
    
    NSUserDefaults * defs = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.myflightbook.mfbapps"];
    self.szAuthToken = [defs stringForKey:_szKeyCachedToken];
    self.fUseHHMM = [defs boolForKey:_szKeyHHMM];
    
    if (self.szAuthToken == nil || self.szAuthToken.length == 0)
    {
        [self.rgData addObject:NSLocalizedString(@"TodayWidgetNoAuth", @"TODAY Widget: no auth")];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
        completionHandler(NCUpdateResultFailed);
    }
    else
    {
        self.onUpdate = completionHandler;
        [self.rgData addObjectsFromArray:@[NSLocalizedString(@"TodayWidgetUpdating", @"TODAY Widget: updating")]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [self makeCall];
    }
}

- (void) widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode withMaximumSize:(CGSize)maxSize {
    if (activeDisplayMode == NCWidgetDisplayModeCompact)
        self.preferredContentSize = self.compactSize;
    else {
        [self.tableView layoutIfNeeded];
        self.preferredContentSize = self.tableView.contentSize;
    }
}

#pragma mark - Table view data source
// Hack, but it avoids showing partial rows in compact mode.
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 2)
        return 55.0f;
    else
        return 44.0f;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rgData.count;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
@end
