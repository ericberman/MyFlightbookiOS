/*
 MyFlightbook for iOS - provides native access to MyFlightbook
 pilot's logbook
 Copyright (C) 2009-2019 MyFlightbook, LLC
 
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
//  GPSDeviceViewTableViewController.m
//  MyFlightbook
//
//  Created by Eric Berman on 2/15/19.
//

#import "GPSDeviceViewTableViewController.h"
#import "MyFlightbook-Swift.h"
#import "Telemetry.h"
#import "NSDate+ISO8601Parsing.h"
#import "NSDate+ISO8601Unparsing.h"

@interface GPSDeviceViewTableViewController ()
@property (strong) CLMutableLocation * loc;
@property (strong) NMEASatelliteStatus * satelliteStatus;
@property (strong) NSMutableString * dataReceived;
@end

@implementation GPSDeviceViewTableViewController

@synthesize eaaccessory, loc, dataReceived, satelliteStatus;

- (NSData *) dataFromHexString:(NSString *) sz {
    NSMutableData * data = [NSMutableData new];
    char rgChars[3];
    rgChars[2] = '\0';
    unsigned char byte;
    for (int i = 0; i < sz.length / 2; i++) {
        rgChars[0] = [sz characterAtIndex:i * 2];
        rgChars[1] = [sz characterAtIndex:i * 2 + 1];
        byte = strtol(rgChars, NULL, 16);
        [data appendBytes:&byte length:1];
    }
    return data;
}

- (BOOL) isBadElf {
    return [self.eaaccessory.name hasPrefix:@"Bad Elf"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loc = nil;
    self.satelliteStatus = nil;
    [EAAccessoryManager.sharedAccessoryManager registerForLocalNotifications];
    if (self.isBadElf) {
        BESessionController * badElfSess = BESessionController.sharedController;
        [badElfSess setupControllerForAccessory:self.eaaccessory withProtocolString:self.eaaccessory.protocolStrings[0]];
        if ([badElfSess openSession]) {
            NSNotificationCenter * notc = NSNotificationCenter.defaultCenter;
            [notc addObserver:self selector:@selector(dataReceived:) name:@"BESessionDataReceivedNotification" object:nil];
            [notc addObserver:self selector:@selector(deviceDisconnected:) name:EAAccessoryDidDisconnectNotification object:nil];
            
            // Get data at 1hz with satellite information
            NSData * data = [self dataFromHexString:@"24be00110b0102ff310132043302630d0a"];
            [badElfSess writeDataWithData:data];
        }
    }
    self.dataReceived = [NSMutableString new];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [BESessionController.sharedController closeSession];
    [EAAccessoryManager.sharedAccessoryManager unregisterForLocalNotifications];
    NSNotificationCenter * notc = NSNotificationCenter.defaultCenter;
    [notc removeObserver:self name:@"BESessionDataReceivedNotification" object:nil];
    [notc removeObserver:self name:EAAccessoryDidDisconnectNotification object:nil];

    self.loc = nil;
    self.dataReceived = nil;
    self.eaaccessory = nil;
}

- (void) dataReceived:(NSNotification *) notification {
    BESessionController * badElfSess = BESessionController.sharedController;
    NSString * sz = badElfSess.dataAsString;
    
    if (sz == nil)
        return;
    
    [self.dataReceived appendString:badElfSess.dataAsString];
    
    NSCharacterSet *separator = [NSCharacterSet newlineCharacterSet];
    NSArray<NSString *> * sentences = [self.dataReceived componentsSeparatedByCharactersInSet:separator];
    
    for (NSString * sentence in sentences) {
        if (sentence.length <= 2)
            continue;
        
        NSObject * result = [NMEAParser parseSentence:sentence];
        if (result != nil) {
            
            // We got some kind of result - trim through this point.
            NSRange r = [self.dataReceived rangeOfString:sentence];
            if (r.location != NSNotFound)
                self.dataReceived = [NSMutableString stringWithString:[self.dataReceived substringFromIndex:r.location + r.length]];
            
            if ([result isKindOfClass:[CLMutableLocation class]]) {
                CLMutableLocation * locPrev = self.loc;
                self.loc = (CLMutableLocation *) result;
                if (locPrev.hasAlt && !self.loc.hasAlt)
                    [self.loc addAlt:locPrev.altitude];
            } else if ([result isKindOfClass:[NMEASatelliteStatus class]]) {
                self.satelliteStatus = (NMEASatelliteStatus *) result;
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void) deviceDisconnected:(NSNotification *) notification {
    self.eaaccessory = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + (self.isBadElf ? 2 : 0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellStatic";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = self.eaaccessory.modelNumber.length > 0 ? [NSString stringWithFormat:@"%@ (%@)", self.eaaccessory.name, self.eaaccessory.modelNumber] : self.eaaccessory.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DeviceSerial", @"Device Serial and firmware"), self.eaaccessory.serialNumber, self.eaaccessory.firmwareRevision];
            if (self.isBadElf)
                cell.imageView.image = [UIImage imageNamed:@"BadElfCircle-Vertical-Transparent"];
            break;
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", [MFBLocation latitudeDisplay:self.loc.latitude], [MFBLocation longitudeDisplay:self.loc.longitude]];
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"DevicePosition", @"Position status"),
                                         self.loc.hasAlt ? [NSString stringWithFormat:@"%.1fft", self.loc.altitude * METERS_TO_FEET] : NSLocalizedString(@"MissingData", @"Device Data Missing"),
                                         self.loc.hasSpeed ? [NSString stringWithFormat:@"%.1fkts", self.loc.speed] : NSLocalizedString(@"MissingData", @"Device Data Missing"),
                                         self.loc.hasTime ? self.loc.timeStamp.ISO8601DateString : @""];
            break;
        case 2:
            cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Satellites", @"Device Satellites"), self.satelliteStatus.satellites.count];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"PDOP: %.1f, HDOP: %.1f, VDOP: %.1f, %@", satelliteStatus.PDOP, satelliteStatus.HDOP, satelliteStatus.VDOP, satelliteStatus.Mode];
            break;
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;

    return cell;
}
@end
