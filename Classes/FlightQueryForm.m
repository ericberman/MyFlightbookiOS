/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2012-2023 MyFlightbook, LLC
 
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
//  FlightQueryViewController.m
//  MFBSample
//
//  Created by Eric Berman on 5/24/12.
//

#import "FlightQueryForm.h"
#import "ExpandHeaderCell.h"
#import "ConjunctionCell.h"

@interface FlightQueryForm ()
@property (nonatomic, strong) MFBWebServiceSvc_FlightQuery * fq;
@property (readwrite) BOOL fSuppressRefresh;
@property (nonatomic, strong) NSMutableArray<MFBWebServiceSvc_CustomPropertyType *> * rgUsedProps;
@property (readwrite) BOOL fShowAllAircraft;

@property (nonatomic, strong) EditCell * ecText;
@property (nonatomic, strong) EditCell * ecModelName;
@property (nonatomic, strong) EditCell * ecAirports;
@property (nonatomic, strong) EditCell * ecQueryName;
@property (nonatomic, strong) ConjunctionCell * conjCellFlightFeatures;
@property (nonatomic, strong) ConjunctionCell * conjCellProps;

+ (NSMutableArray<MFBWebServiceSvc_CannedQuery *> *) rgCannedQueries;
+ (void) setRgCannedProperties:(NSMutableArray<MFBWebServiceSvc_CannedQuery *> *) value;
@end

@implementation FlightQueryForm

@synthesize delegate, fq, ecText, ecAirports, ecModelName, ecQueryName, fSuppressRefresh, fShowAllAircraft, conjCellFlightFeatures, conjCellProps;

typedef enum _fqSections {fqsText = 0, 
fqsDate, 
fqsAirports, 
fqsAircraft, 
fqsAircraftFeatures, 
fqsMakes,
fqsCatClass,
fqsFlightFeatures,
fqsProperties,
fqsNamedQueries,
fqsMax = fqsNamedQueries
    
} fqSections;

// aircraft features
typedef enum _afRows {afTailwheel = 1, afHighPerf, afGlass, afTAA, afComplex, afRetract, afCSProp, afFlaps, afMotorGlider, afMultiEngineHeli,
    afEngineAny, afEnginePiston, afEngineTurboProp, afEngineJet, afEngineTurbine, afEngineElectric,
    afInstanceAny, afInstanceReal, afInstanceTraining, afMax = afInstanceTraining} afRows;

typedef enum _ffRows {ffConjunction = 1, ffAnyLandings, ffFSLanding, ffFSNightLanding, ffApproaches, ffHold, ffXC, ffSimIMC, ffActualIMC, ffAnyInstrument, ffGroundSim, ffNight,
ffDual, ffCFI, ffSIC, ffPIC, ffTotalTime, ffIsPublic, ffTelemetry, ffImages, ffSigned, ffMax = ffSigned} ffRows;

static NSArray * makesInUse = nil;

BOOL fSkipLoadText = NO;

static NSMutableArray<MFBWebServiceSvc_CannedQuery *> * _rgCannedQueries;

#pragma mark Canned Properties
+ (NSMutableArray<MFBWebServiceSvc_CannedQuery *> *) rgCannedQueries {
    @synchronized(self) { return _rgCannedQueries; }
}

+ (void) setRgCannedProperties:(NSMutableArray<MFBWebServiceSvc_CannedQuery *> *) value {
    @synchronized(self) { _rgCannedQueries = value; }
}

#pragma mark Data Management
- (void) refreshMakes
{
    if (makesInUse != nil)
        return;
    
    NSArray * modelsInUse = [[Aircraft sharedAircraft] modelsInUse];
    
    NSMutableArray * mutableMakes = [NSMutableArray new];
    for (MFBWebServiceSvc_SimpleMakeModel * smm in modelsInUse)
    {
        MFBWebServiceSvc_MakeModel * mm = [[MFBWebServiceSvc_MakeModel alloc] init];
        mm.MakeModelID = smm.ModelID;
        mm.ModelName = smm.Description;
        [mutableMakes addObject:mm];
    }
    makesInUse = mutableMakes;
    [self.tableView reloadData];
}

- (void) updateMakesCompleted:(MFBSoapCall *) sc fromCaller:(Aircraft *) a
{
    [Aircraft sharedAircraft].rgMakeModels = a.rgMakeModels; // update the global list.
    [self refreshMakes];
}

- (void) UpdateMakes
{	
    Aircraft * a = [[Aircraft alloc] init];
    [a setDelegate:self completionBlock:^(MFBSoapCall * sc, MFBAsyncOperation * ao) {
        [self updateMakesCompleted:sc fromCaller:(Aircraft *)ao];
    }];
    [a loadMakeModels];
}

- (void) initMakes
{
    if ([Aircraft sharedAircraft].rgMakeModels == nil)
		[self UpdateMakes];
    else
        [self refreshMakes];
}

- (void) refreshUsedProps
{
    FlightProps * fp = [FlightProps getFlightPropsNoNet];
    self.rgUsedProps = [[NSMutableArray alloc] init];
    
    for (MFBWebServiceSvc_CustomPropertyType * cpt in fp.rgPropTypes)
        if (cpt.IsFavorite.boolValue)
            [self.rgUsedProps addObject:cpt];
    
    if (self.rgUsedProps.count == 0)    // no previously used properties loaded - just show 'em all!
        self.rgUsedProps = [NSMutableArray arrayWithArray:fp.rgPropTypes];
}

- (void) resetFlight
{
    self.fq = (MFBWebServiceSvc_FlightQuery *) [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    [self.expandedSections removeAllIndexes];
    self.ecText.txt.text = @"";
    self.ecAirports.txt.text = @"";
    self.conjCellFlightFeatures.conjunction = self.fq.FlightCharacteristicsConjunction;
    self.conjCellProps.conjunction = self.fq.PropertiesConjunction;
    [self.tableView reloadData];
}

- (void) loadText
{
    if (fSkipLoadText)
        return;
    
    // update the text fields
    self.fq.GeneralText = self.ecText.txt.text;
    self.fq.ModelName = self.ecModelName.txt.text;

    if (self.ecAirports != nil) {
        NSString * szAirports = self.ecAirports.txt.text;
        NSError * err = NULL;
        NSRegularExpression * reAirports = [[NSRegularExpression alloc] initWithPattern:@"!?@?[a-zA-Z0-9]+!?" options:NSRegularExpressionCaseInsensitive error:&err];
        NSArray *matches = [reAirports matchesInString:szAirports options:0 range:NSMakeRange(0, szAirports.length)];
        [self.fq.AirportList.string removeAllObjects];
        for (NSTextCheckingResult * match in matches)
            [self.fq.AirportList.string addObject:[szAirports substringWithRange:match.range]];
    }
    
    if (self.ecQueryName.txt.text.length > 0 && !fSkipLoadText)
        [self AddCannedQuery:self.fq withName:self.ecQueryName.txt.text];

}

// Determines the number of aircraft to hide.
// This is 0 if:
// a) The user has clicked on "show all aircraft"
// b) All aircraft are active
// c) The current query references an inactive aircraft
// Otherwise, it is the number of hidden (inactive) aircraft
- (NSInteger) numberHiddenAircraft {
    NSArray * rgAllAircraft = [Aircraft sharedAircraft].rgAircraftForUser;
    if (self.fShowAllAircraft)
        return 0;
    
    NSArray * rgActiveAircraft = [[Aircraft sharedAircraft] AircraftForSelection:@-1];
    
    // check for all aircraft are active
    if (rgAllAircraft.count == rgActiveAircraft.count) {
        self.fShowAllAircraft = YES;
        return 0;
    }
    
    for (MFBWebServiceSvc_Aircraft * ac in self.fq.AircraftList.Aircraft) {
        if (![rgActiveAircraft containsObject:ac]) {
            self.fShowAllAircraft = YES;
            return 0;
        }
    }
    
    return rgAllAircraft.count - rgActiveAircraft.count;
}

- (NSArray *) availableAircraft {
    return self.numberHiddenAircraft == 0 ? [Aircraft sharedAircraft].rgAircraftForUser : [[Aircraft sharedAircraft] AircraftForSelection:@-1];
}

#pragma mark Object Lifecycle
- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.delegate = nil;
        self.fq = [MFBWebServiceSvc_FlightQuery getNewFlightQuery];
    }
    return self;
}

- (void) didReceiveMemoryWarning
{
    if (makesInUse != nil)
    {
        makesInUse = nil;
    }
    [super didReceiveMemoryWarning];
}

#pragma mark - canned query management
- (void) refreshCannedQueries {
    if (!mfbApp().isOnLine)
        return;
    
    NSString * authtoken = mfbApp().userProfile.AuthToken;
    if ([authtoken length] == 0)
        return;

    MFBWebServiceSvc_GetNamedQueriesForUser * gnqSVC = [MFBWebServiceSvc_GetNamedQueriesForUser new];
    gnqSVC.szAuthToken = authtoken;

    MFBSoapCall * sc = [[MFBSoapCall alloc] init];
    sc.logCallData = NO;
    sc.delegate = self;
    
    [sc makeCallAsync:^(MFBWebServiceSoapBinding * b, MFBSoapCall * sc) {
        [b GetNamedQueriesForUserAsyncUsingParameters:gnqSVC delegate:sc];
    }];
}

- (void) deleteCannedQuery:(MFBWebServiceSvc_CannedQuery *) fq {
    if (!mfbApp().isOnLine)
        return;

    NSString * authtoken = mfbApp().userProfile.AuthToken;
    if ([authtoken length] == 0)
        return;
    
    MFBWebServiceSvc_DeleteNamedQueryForUser * dnqSVC = [MFBWebServiceSvc_DeleteNamedQueryForUser new];
    dnqSVC.szAuthToken = authtoken;
    dnqSVC.cq = fq;
    MFBSoapCall * sc = [[MFBSoapCall alloc] init];
    sc.logCallData = NO;
    sc.delegate = self;
    
    [sc makeCallAsync:^(MFBWebServiceSoapBinding *b, MFBSoapCall *sc) {
        [b DeleteNamedQueryForUserAsyncUsingParameters:dnqSVC delegate:sc];
    }];
}

- (void) AddCannedQuery:(MFBWebServiceSvc_FlightQuery *) fq withName:(NSString *) szName {
    if (!mfbApp().isOnLine)
        return;
    
    NSString * authtoken = mfbApp().userProfile.AuthToken;
    if ([authtoken length] == 0)
        return;
    
    if (fq == nil || fq.isUnrestricted)
        return;
    
    MFBWebServiceSvc_AddNamedQueryForUser * anqSVC = [MFBWebServiceSvc_AddNamedQueryForUser new];
    anqSVC.szAuthToken = authtoken;
    anqSVC.fq = fq;
    anqSVC.szName = szName;
    
    MFBSoapCall * sc = [[MFBSoapCall alloc] init];
    sc.logCallData = NO;
    sc.delegate = self;
    
    [sc makeCallAsync:^(MFBWebServiceSoapBinding * b, MFBSoapCall * sc) {
        [b AddNamedQueryForUserAsyncUsingParameters:anqSVC delegate:sc];
    }];
}

- (void) BodyReturned:(id)body
{
    if ([body isKindOfClass:[MFBWebServiceSvc_GetNamedQueriesForUserResponse class]]) {
        MFBWebServiceSvc_GetNamedQueriesForUserResponse * resp = (MFBWebServiceSvc_GetNamedQueriesForUserResponse *) body;
        FlightQueryForm.rgCannedProperties = resp.GetNamedQueriesForUserResult.CannedQuery;
    }
    else if ([body isKindOfClass:[MFBWebServiceSvc_DeleteNamedQueryForUserResponse class]]) {
        MFBWebServiceSvc_DeleteNamedQueryForUserResponse * resp = (MFBWebServiceSvc_DeleteNamedQueryForUserResponse *) body;
        FlightQueryForm.rgCannedProperties = resp.DeleteNamedQueryForUserResult.CannedQuery;
    }
    else if ([body isKindOfClass:[MFBWebServiceSvc_AddNamedQueryForUserResponse class]]) {
        MFBWebServiceSvc_AddNamedQueryForUserResponse * resp = (MFBWebServiceSvc_AddNamedQueryForUserResponse *) body;
        FlightQueryForm.rgCannedProperties = resp.AddNamedQueryForUserResult.CannedQuery;
    }
}

- (void) ResultCompleted:(MFBSoapCall *)sc {
    [self.tableView reloadData];
    // silently fail any error, since this is all background anyhow.  But still log it
    if (sc.errorString.length > 0)
        NSLog(@"CannedQuery error: %@", sc.errorString);
}

#pragma mark - load/unload
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initMakes];
    [self refreshUsedProps];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    UIBarButtonItem * biReset = [[UIBarButtonItem alloc] 
                                  initWithTitle:NSLocalizedString(@"Reset", @"Reset button on flight entry") 
                                  style:UIBarButtonItemStylePlain
                                  target:self 
                                  action:@selector(resetFlight)];
    self.navigationItem.rightBarButtonItem = biReset;
    self.navigationItem.title = NSLocalizedString(@"FindFlights", @"Find Flights title");
    
    if (FlightQueryForm.rgCannedQueries == nil)
        [self refreshCannedQueries];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self loadText];
    if (self.conjCellFlightFeatures != nil)
        self.fq.FlightCharacteristicsConjunction = self.conjCellFlightFeatures.conjunction;
    if (self.conjCellProps != nil)
        self.fq.PropertiesConjunction = self.conjCellProps.conjunction;
    if (self.fSuppressRefresh)
    {
        self.fSuppressRefresh = NO;
        return;
    }
    if (self.delegate != nil)
        [self.delegate queryUpdated:self.fq];
    
    [super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    fSkipLoadText = NO;
}

#pragma mark Utility functions
+ (NSString *) stringForDateRange:(MFBWebServiceSvc_DateRanges) dr
{
    switch (dr) {
        case MFBWebServiceSvc_DateRanges_AllTime:
        case MFBWebServiceSvc_DateRanges_none:
            return NSLocalizedString(@"All Time", @"Totals - All Time");
        case MFBWebServiceSvc_DateRanges_Trailing12Months:
            return NSLocalizedString(@"12 Months", @"Totals - Trailing 12 months");
        case MFBWebServiceSvc_DateRanges_Tailing6Months:
            return NSLocalizedString(@"6 Months", @"Totals - Trailing 6 months");
        case MFBWebServiceSvc_DateRanges_YTD:
            return NSLocalizedString(@"YTD", @"Totals - Year-to-date");
        case MFBWebServiceSvc_DateRanges_PrevMonth:
            return NSLocalizedString(@"Previous Month", @"Totals - Previous Month");
        case MFBWebServiceSvc_DateRanges_PrevYear:
            return NSLocalizedString(@"Previous Year", @"Totals - Previous Year");
        case MFBWebServiceSvc_DateRanges_ThisMonth:
            return NSLocalizedString(@"This Month", @"Totals - This month");
        case MFBWebServiceSvc_DateRanges_Trailing30:
            return NSLocalizedString(@"Trailing 30", @"Totals - Trailing 30 days");
        case MFBWebServiceSvc_DateRanges_Trailing90:
            return NSLocalizedString(@"Trailing 90", @"Totals - Trailing 90 days");
        default:
            return @"";
    }
}

#pragma mark - Expand/collapse functions
- (BOOL) canExpandSection:(NSInteger) section
{
    switch (section)
    {
        case fqsAircraft:
        case fqsDate:
        case fqsMakes:
        case fqsAirports:
        case fqsAircraftFeatures:
        case fqsFlightFeatures:
        case fqsCatClass:
        case fqsProperties:
        case fqsNamedQueries:
            return YES;
        case fqsText:
        default:
            return NO;
    }
}

- (void) autoExpand
{
    if (self.fq == nil)
        return;
    [self.expandedSections removeAllIndexes];
    if ([self.fq hasDate])
        [self.expandedSections addIndex:fqsDate];
    if ([self.fq hasAircraft])
        [self.expandedSections addIndex:fqsAircraft];
    if ([self.fq hasMakes])
        [self.expandedSections addIndex:fqsMakes];
    if ([self.fq hasAirport])
        [self.expandedSections addIndex:fqsAirports];
    if ([self.fq hasAircraftCharacteristics])
        [self.expandedSections addIndex:fqsAircraftFeatures];
    if ([self.fq hasCatClasses])
        [self.expandedSections addIndex:fqsCatClass];
    if ([self.fq hasFlightCharacteristics])
        [self.expandedSections addIndex:fqsFlightFeatures];
    if ([self.fq hasProperties])
        [self.expandedSections addIndex:fqsProperties];
    if (FlightQueryForm.rgCannedQueries.count > 0)
        [self.expandedSections addIndex:fqsNamedQueries];
}

- (NSInteger) rowsInSection:(NSInteger) section withItemCount:(NSInteger) items
{
    if ([self canExpandSection:section])
    {
        if ([self isExpanded:section])
            return items + 1;
        else
            return 1;
    }
    else
        return items;
}

- (void) setQuery:(MFBWebServiceSvc_FlightQuery *) f
{
    self.fq = f;
    [self autoExpand];
}

#pragma mark - Cell types


- (UITableViewCell *) getSubtitleCell
{
    static NSString *CellIdentifier = @"CellSubtitle";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.detailTextLabel.text = @"";
    return cell;
}

- (UITableViewCell *) getSmallSubtitleCell
{
    static NSString *CellIdentifier = @"CellSubtitleSmall";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    return cell;
}

#pragma mark - Table view data source
- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {return nil; }
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {return nil; }

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == fqsNamedQueries)
        return NSLocalizedString(@"QueryNameHeaderDesc", "@Query name header description");
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return fqsMax + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case fqsText:
            return 1;
        case fqsAirports:
            return [self rowsInSection:section withItemCount:4];
        case fqsDate:
            return [self rowsInSection:section withItemCount:MFBWebServiceSvc_DateRanges_Custom];
        case fqsAircraft:
            return [self rowsInSection:section withItemCount:self.availableAircraft.count + (self.fShowAllAircraft ? 0 : 1)];
        case fqsMakes:
            return [self rowsInSection:section withItemCount:[makesInUse count] + 1];
        case fqsAircraftFeatures:
            return [self rowsInSection:section withItemCount:afMax];
        case fqsFlightFeatures:
            return [self rowsInSection:section withItemCount:ffMax];
        case fqsCatClass:
            return [self rowsInSection:section withItemCount:MFBWebServiceSvc_CatClassID_PoweredParaglider];
        case fqsProperties:
            return [self rowsInSection:section withItemCount:self.rgUsedProps.count + 1];
        case fqsNamedQueries:
            return [self rowsInSection:fqsNamedQueries withItemCount: 1 + FlightQueryForm.rgCannedQueries.count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case fqsDate:
            {
                if (indexPath.row == 0) // header row
                    return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"FlightDate", @"Date criteria") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
                
                UITableViewCell *cell = [self getSubtitleCell];
                MFBWebServiceSvc_DateRanges dr = (MFBWebServiceSvc_DateRanges) indexPath.row;
                
                if (dr == MFBWebServiceSvc_DateRanges_Custom)
                {
                    cell.textLabel.text = NSLocalizedString(@"Date Range", @"Select Dates for totals");
                    if (self.fq.DateRange == dr)
                    {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        NSDateFormatter * df = [NSDateFormatter new];
                        [df setDateFormat:@"MMM dd, yyyy"];
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", 
                                                     [df stringFromDate:[MFBSoapCall LocalDateFromUTCDate:self.fq.DateMin]],
                                                     [df stringFromDate:[MFBSoapCall LocalDateFromUTCDate:self.fq.DateMax]]];
                    }
                    else
                    {
                        cell.detailTextLabel.text = @"";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }                
                }
                else {
                    cell.textLabel.text = [FlightQueryForm stringForDateRange:dr];
                    cell.accessoryType = (dr == self.fq.DateRange) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = @"";                
                }
                return cell;
            }
        case fqsText:
            {
                if (indexPath.row == 0) // general text
                {
                    if (self.ecText != nil)
                        return self.ecText;
                    
                    self.ecText = [EditCell getEditCell:self.tableView withAccessory:nil];
                    self.ecText.lbl.text = NSLocalizedString(@"TextContains", @"General Text");
                    self.ecText.txt.text = fq.GeneralText;
                    self.ecText.txt.placeholder = NSLocalizedString(@"TextContainsPrompt", @"General Text Prompt");
                    self.ecText.txt.returnKeyType = UIReturnKeyDone;
                    self.ecText.txt.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                    [self.ecText.txt setDelegate:self];
                    return self.ecText;
                }
                @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in FlightQueryForm with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
            }
        case fqsAirports:
            if (indexPath.row == 0)
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"AirportsVisited", "Airport Criteria") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            
            if (indexPath.row == 1) // airports (0 is header cell)
            {
                if (self.ecAirports != nil)
                    return self.ecAirports;
                
                self.ecAirports = [EditCell getEditCell:self.tableView withAccessory:nil];
                self.ecAirports.lbl.text = NSLocalizedString(@"AirportsVisited", @"Airport Criteria");
                self.ecAirports.txt.text = [fq.AirportList.string componentsJoinedByString:@" "];
                self.ecAirports.txt.placeholder = NSLocalizedString(@"AirportsVisitedPrompt", @"Airport Criteria Prompt");
                self.ecAirports.txt.returnKeyType = UIReturnKeyDone;
                self.ecAirports.txt.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
                [self.ecAirports.txt setDelegate:self];
                return self.ecAirports;
            }
            else {
                UITableViewCell * cell = [self getSubtitleCell];
                MFBWebServiceSvc_FlightDistance Distance = (MFBWebServiceSvc_FlightDistance) (indexPath.row - 1);
                cell.accessoryType = (Distance == self.fq.Distance) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                switch (Distance)
                {
                    case MFBWebServiceSvc_FlightDistance_none:
                    case MFBWebServiceSvc_FlightDistance_AllFlights:
                        cell.textLabel.text = NSLocalizedString(@"FlightQueryDistanceAllFlights", @"All flights that visit a given airport");
                        break;
                    case MFBWebServiceSvc_FlightDistance_LocalOnly:
                        cell.textLabel.text = NSLocalizedString(@"FlightQueryDistanceLocalFlights", @"Local flights only at a given airport");
                        break;
                    case MFBWebServiceSvc_FlightDistance_NonLocalOnly:
                        cell.textLabel.text = NSLocalizedString(@"FlightQueryDistanceNonLocalFlights", @"Non-local flights that left or arrived at a given airport");
                        break;
                }
                return cell;
            }
        case fqsCatClass:
        {
            if (indexPath.row == 0) // header row
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"ccHeader", @"Category-class Criteria") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            
            UITableViewCell *cell = [self getSubtitleCell];
            MFBWebServiceSvc_CategoryClass * cc = [[MFBWebServiceSvc_CategoryClass alloc] initWithID:(MFBWebServiceSvc_CatClassID)indexPath.row];
            
            cell.textLabel.text = cc.localizedDescription;
            cell.detailTextLabel.text =  @"";
            cell.accessoryType = [self.fq.CatClasses.CategoryClass containsObject:cc] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case fqsAircraft:
        {
            if (indexPath.row == 0) // header row
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"FlightAircraft", @"Aircraft Criteria") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];

            UITableViewCell *cell = [self getSubtitleCell];
            NSArray * rgAircraft = self.availableAircraft;
            if (!self.fShowAllAircraft && indexPath.row == rgAircraft.count + 1) {
                cell.textLabel.text = NSLocalizedString(@"ShowAllAircraft", @"Show all aircraft");
                cell.detailTextLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
                
            MFBWebServiceSvc_Aircraft * ac = (MFBWebServiceSvc_Aircraft *) rgAircraft[indexPath.row - 1];
            cell.textLabel.text = ac.TailNumber;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", ac.ModelCommonName, ac.ModelDescription];
            cell.accessoryType = [self.fq.AircraftList.Aircraft containsObject:ac] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case fqsMakes:
        {
            NSInteger row = indexPath.row;
            if (row == 0) // header row
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"FlightModel", @"Make/Model Criteria") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            
            if (row == makesInUse.count + 1)  // modelname field
            {
                self.ecModelName = [EditCell getEditCell:self.tableView withAccessory:nil];
                self.ecModelName.lbl.text = NSLocalizedString(@"FlightModelName", @"Model Free-text");
                self.ecModelName.txt.text = fq.ModelName;
                self.ecModelName.txt.placeholder = NSLocalizedString(@"FlightModelNamePrompt", @"Model Free-text Prompt");
                self.ecModelName.txt.returnKeyType = UIReturnKeyDone;
                self.ecModelName.txt.autocapitalizationType = UITextAutocapitalizationTypeSentences;
                [self.ecModelName.txt setDelegate:self];
                return self.ecModelName;
            }
            else
            {
                UITableViewCell *cell = [self getSmallSubtitleCell];
                MFBWebServiceSvc_MakeModel * mm = (MFBWebServiceSvc_MakeModel *)makesInUse[row - 1];
                cell.textLabel.text = mm.ModelName;
                cell.detailTextLabel.text = @"";
                cell.accessoryType = [self.fq.MakeList.MakeModel containsObject:mm] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                return cell;
            }
        }
        case fqsFlightFeatures:
        {
            if (indexPath.row == 0) // header row
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"FlightFeatures", @"Flight Features") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            
            if (indexPath.row == ffConjunction) {
                if (self.conjCellFlightFeatures == nil)
                    self.conjCellFlightFeatures = [ConjunctionCell getConjunctionCell:tableView withConjunction:self.fq.FlightCharacteristicsConjunction];
                return self.conjCellFlightFeatures;
            }
            
            UITableViewCell * cell = [self getSubtitleCell];
            switch (indexPath.row)
            {
                case ffActualIMC:
                    cell.textLabel.text = NSLocalizedString(@"ffIMC", @"Flight has actual IMC time");
                    cell.accessoryType = self.fq.HasIMC.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffSimIMC:
                    cell.textLabel.text = NSLocalizedString(@"ffSimIMC", @"Flight has simulated IMC");
                    cell.accessoryType = self.fq.HasSimIMCTime.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffAnyInstrument:
                    cell.textLabel.text = NSLocalizedString(@"ffAnyInstrument", @"Flight has ANY instrument");
                    cell.accessoryType = self.fq.HasAnyInstrument.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffApproaches:
                    cell.textLabel.text = NSLocalizedString(@"ffApproaches", @"Flight has instrument approaches");
                    cell.accessoryType = self.fq.HasApproaches.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffCFI:
                    cell.textLabel.text = NSLocalizedString(@"ffCFI", @"Flight has CFI time logged");
                    cell.accessoryType = self.fq.HasCFI.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffDual:
                    cell.textLabel.text = NSLocalizedString(@"ffDual", @"Flight has Dual time logged");
                    cell.accessoryType = self.fq.HasDual.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffFSLanding:
                    cell.textLabel.text = NSLocalizedString(@"ffFSLanding", @"Flight has full-stop landings");
                    cell.accessoryType = self.fq.HasFullStopLandings.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffFSNightLanding:
                    cell.textLabel.text = NSLocalizedString(@"ffFSNightLanding", @"Flight has full-stop night-landings");
                    cell.accessoryType = self.fq.HasNightLandings.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffAnyLandings:
                    cell.textLabel.text = NSLocalizedString(@"ffLandings", @"Flight has landings");
                    cell.accessoryType = self.fq.HasLandings.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffGroundSim:
                    cell.textLabel.text = NSLocalizedString(@"ffGroundSim", @"Flight has Ground Sim");
                    cell.accessoryType = self.fq.HasGroundSim.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffHold:
                    cell.textLabel.text = NSLocalizedString(@"ffHold", @"Flight has holding procedures");
                    cell.accessoryType = self.fq.HasHolds.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffIsPublic:
                    cell.textLabel.text = NSLocalizedString(@"ffIsPublic", @"Flight is public");
                    cell.accessoryType = self.fq.IsPublic.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffNight:
                    cell.textLabel.text = NSLocalizedString(@"ffNight", @"Flight has night flight time");
                    cell.accessoryType = self.fq.HasNight.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffPIC:
                    cell.textLabel.text = NSLocalizedString(@"ffPIC", @"Aircraft Feature = Tailwheel");
                    cell.accessoryType = self.fq.HasPIC.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffSIC:
                    cell.textLabel.text = NSLocalizedString(@"ffSIC", @"Flight has SIC time logged");
                    cell.accessoryType = self.fq.HasSIC.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffTotalTime:
                    cell.textLabel.text = NSLocalizedString(@"ffTotal", @"Flight has Total Time logged");
                    cell.accessoryType = self.fq.HasTotalTime.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffTelemetry:
                    cell.textLabel.text = NSLocalizedString(@"ffTelemetry", @"Flight has Telemetry Data");
                    cell.accessoryType = self.fq.HasTelemetry.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffImages:
                    cell.textLabel.text = NSLocalizedString(@"ffImages", @"Flight has Images or Videos");
                    cell.accessoryType = self.fq.HasImages.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffXC:
                    cell.textLabel.text = NSLocalizedString(@"ffXC", @"Flight has PIC time logged");
                    cell.accessoryType = self.fq.HasXC.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case ffSigned:
                    cell.textLabel.text = NSLocalizedString(@"ffSigned", @"Flight is signed");
                    cell.accessoryType = self.fq.IsSigned.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            return cell;
        }
        case fqsProperties:
        {
            if (indexPath.row == 0) // header row
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"Properties", @"Properties Header") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            if (indexPath.row == 1) {
                if (self.conjCellProps == nil)
                    self.conjCellProps = [ConjunctionCell getConjunctionCell:tableView withConjunction:self.fq.PropertiesConjunction];
                return self.conjCellProps;
            }
            
            UITableViewCell * cell = [self getSubtitleCell];
            MFBWebServiceSvc_CustomPropertyType * cpt = (MFBWebServiceSvc_CustomPropertyType *)self.rgUsedProps[indexPath.row - 2];
            cell.textLabel.text = cpt.Title;
            cell.accessoryType = [self.fq hasPropertyType:cpt] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            return cell;
        }
        case fqsAircraftFeatures:
        {
            if (indexPath.row == 0) // header row
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"AircraftFeatures", @"Aircraft Features for search") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            
            UITableViewCell * cell = [self getSubtitleCell];
            switch (indexPath.row)
            {
                case afTailwheel:
                    cell.textLabel.text = NSLocalizedString(@"afTailwheel", @"Aircraft Feature = Tailwheel");
                    cell.accessoryType = self.fq.IsTailwheel.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afHighPerf:
                    cell.textLabel.text = NSLocalizedString(@"afHighPerf", @"Aircraft Feature = High Performance");
                    cell.accessoryType = self.fq.IsHighPerformance.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afGlass:
                    cell.textLabel.text = NSLocalizedString(@"afGlass", @"Aircraft Feature = Glass Cockpit");
                    cell.accessoryType = self.fq.IsGlass.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afTAA:
                    cell.textLabel.text = NSLocalizedString(@"afTAA", @"Aircraft Features = TAA");
                    cell.accessoryType = self.fq.IsTechnicallyAdvanced.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afComplex:
                    cell.textLabel.text = NSLocalizedString(@"afComplex", @"Aircraft Feature = Complex");
                    cell.accessoryType = self.fq.IsComplex.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afRetract:
                    cell.textLabel.text = NSLocalizedString(@"afRetract", @"Aircraft Feature = Retractable gear");
                    cell.accessoryType = self.fq.IsRetract.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afCSProp:
                    cell.textLabel.text = NSLocalizedString(@"afCSProp", @"Aircraft Feature = Controllable Pitch Propellor");
                    cell.accessoryType = self.fq.IsConstantSpeedProp.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afFlaps:
                    cell.textLabel.text = NSLocalizedString(@"afFlaps", @"Aircraft Feature = Flaps");
                    cell.accessoryType = self.fq.HasFlaps.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afMotorGlider:
                    cell.textLabel.text = NSLocalizedString(@"afMotorGlider", @"Aircraft Feature = Motorglider");
                    cell.accessoryType = self.fq.IsMotorglider.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afMultiEngineHeli:
                    cell.textLabel.text = NSLocalizedString(@"afMultiHeli", @"Aircraft Feature = Multi-Engine Helicopter");
                    cell.accessoryType = self.fq.IsMultiEngineHeli.boolValue ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afEngineAny:
                    cell.textLabel.text = NSLocalizedString(@"afEngineAny", @"Aircraft Feature = Engine Type Any");
                    cell.accessoryType = (self.fq.EngineType == MFBWebServiceSvc_EngineTypeRestriction_AllEngines) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afEngineJet:
                    cell.textLabel.text = NSLocalizedString(@"afEngineJet", @"Aircraft Feature = Engine Type Jet");
                    cell.accessoryType = (self.fq.EngineType == MFBWebServiceSvc_EngineTypeRestriction_Jet) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afEnginePiston:
                    cell.textLabel.text = NSLocalizedString(@"afEnginePiston", @"Aircraft Feature = Engine Type Piston");
                    cell.accessoryType = (self.fq.EngineType == MFBWebServiceSvc_EngineTypeRestriction_Piston) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afEngineTurbine:
                    cell.textLabel.text = NSLocalizedString(@"afEngineTurbine", @"Aircraft Feature = Turbine (Any) ");
                    cell.accessoryType = (self.fq.EngineType == MFBWebServiceSvc_EngineTypeRestriction_AnyTurbine) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afEngineElectric:
                    cell.textLabel.text = NSLocalizedString(@"afEngineElectric", @"Aircraft Feature = Engine Type Electric");
                    cell.accessoryType = (self.fq.EngineType == MFBWebServiceSvc_EngineTypeRestriction_Electric) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afEngineTurboProp:
                    cell.textLabel.text = NSLocalizedString(@"afEngineTurboprop", @"Aircraft Feature = TurboProp");
                    cell.accessoryType = (self.fq.EngineType == MFBWebServiceSvc_EngineTypeRestriction_Turboprop) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afInstanceAny:
                    cell.textLabel.text = NSLocalizedString(@"afInstanceAny", @"Any Aircraft");
                    cell.accessoryType = (self.fq.AircraftInstanceTypes == MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afInstanceReal:
                    cell.textLabel.text = NSLocalizedString(@"afInstanceReal", @"Real Aircraft");
                    cell.accessoryType = (self.fq.AircraftInstanceTypes == MFBWebServiceSvc_AircraftInstanceRestriction_RealOnly) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
                case afInstanceTraining:
                    cell.textLabel.text = NSLocalizedString(@"afInstanceTraining", @"Training Device");
                    cell.accessoryType = (self.fq.AircraftInstanceTypes == MFBWebServiceSvc_AircraftInstanceRestriction_TrainingOnly) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
                    break;
            }
            return cell;
        }
            break;
        case fqsNamedQueries: {
            if (indexPath.row == 0) // header row
                return [ExpandHeaderCell getHeaderCell:self.tableView withTitle:NSLocalizedString(@"QueryNameHeader", @"Header for query names") forSection:indexPath.section initialState:[self isExpanded:indexPath.section]];
            else if (indexPath.row == 1) {
                self.ecQueryName = [EditCell getEditCell:self.tableView withAccessory:nil];
                self.ecQueryName.lbl.text = NSLocalizedString(@"QueryNamePrompt", @"Prompt for query name");
                self.ecQueryName.txt.placeholder = NSLocalizedString(@"QueryNamePrompt", @"Prompt for query name");
                self.ecQueryName.txt.returnKeyType = UIReturnKeyDone;
                self.ecQueryName.txt.autocapitalizationType = UITextAutocapitalizationTypeWords;
                [self.ecQueryName.txt setDelegate:self];
                return self.ecQueryName;
            }
            else {
                UITableViewCell * cell = [self getSubtitleCell];
                cell.textLabel.text = FlightQueryForm.rgCannedQueries[indexPath.row - 2].QueryName;
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
        }
            break;
    }
    
    @throw [NSException exceptionWithName:@"Invalid indexpath" reason:@"Request for cell in FlightQuery with invalid indexpath" userInfo:@{@"indexPath:" : indexPath}];
}

#pragma mark - Table view delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return  ([mfbApp() isOnLine] && indexPath.section == fqsNamedQueries && indexPath.row >= 2);
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (![self tableView:tableView canEditRowAtIndexPath:indexPath])
            return;

        MFBWebServiceSvc_CannedQuery * cq = FlightQueryForm.rgCannedQueries[indexPath.row - 2];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"QueryDeleteConfirm", @"Confirm Delete Named Query") preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK") style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self deleteCannedQuery:cq];
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel (button)") style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) { }]];
        [self presentViewController:alertController animated:YES completion:^{}];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // check for header row; just handle it here.
    if (indexPath.row == 0 && [self canExpandSection:indexPath.section])
    {
        [self toggleSection:indexPath.section];
        return;
    }
    
    switch (indexPath.section) {
        case fqsDate:
            self.fq.DateRange = (MFBWebServiceSvc_DateRanges) indexPath.row;
            if (self.fq.DateRange == MFBWebServiceSvc_DateRanges_Custom)
            {
                DateRangeViewController * drs = [[DateRangeViewController alloc] initWithNibName:@"DateRangeViewController" bundle:nil];
                drs.delegate = self;
                drs.dtStart = [MFBSoapCall LocalDateFromUTCDate:self.fq.DateMin];
                drs.dtEnd = [MFBSoapCall LocalDateFromUTCDate:self.fq.DateMax];
                self.fSuppressRefresh = YES;
                [self.navigationController pushViewController:drs animated:YES];
            }
            else
                [self.tableView reloadData];
            break;
        case fqsAircraft:
            {
                NSArray * rgAircraft = self.availableAircraft;
                if (!self.fShowAllAircraft && indexPath.row == rgAircraft.count + 1) {
                    // show all
                    NSInteger newRowCount = self.numberHiddenAircraft - 1;  // remove one for the "Show all" row
                    self.fShowAllAircraft = YES;
                    NSMutableArray * rg = [[NSMutableArray alloc] initWithCapacity:newRowCount];
                    for (int i = 1; i <= newRowCount; i++)
                        [rg addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                    
                    [self.tableView insertRowsAtIndexPaths:rg withRowAnimation:UITableViewRowAnimationTop];
                }
                else {
                    MFBWebServiceSvc_Aircraft * ac = (MFBWebServiceSvc_Aircraft *)rgAircraft[indexPath.row - 1];
                    if ([self.fq.AircraftList.Aircraft containsObject:ac])
                        [self.fq.AircraftList.Aircraft removeObject:ac];
                    else
                        [self.fq.AircraftList.Aircraft addObject:ac];
                }
                [self.tableView reloadData];
            }
            break;
        case fqsCatClass:
            {
                MFBWebServiceSvc_CategoryClass * cc = [[MFBWebServiceSvc_CategoryClass alloc] initWithID:(MFBWebServiceSvc_CatClassID)indexPath.row];
                if ([self.fq.CatClasses.CategoryClass containsObject:cc])
                    [self.fq.CatClasses.CategoryClass removeObject:cc];
                else
                    [self.fq.CatClasses.CategoryClass addObject:cc];
                [self.tableView reloadData];
            }
            break;
        case fqsAirports:
            self.fq.Distance = (MFBWebServiceSvc_FlightDistance) (indexPath.row - 1);
            [self.tableView reloadData];
            break;
        case fqsMakes:
            {
                MFBWebServiceSvc_MakeModel * mm = (MFBWebServiceSvc_MakeModel *)makesInUse[indexPath.row - 1];
                if ([self.fq.MakeList.MakeModel containsObject:mm])
                    [self.fq.MakeList.MakeModel removeObject:mm];
                else
                    [self.fq.MakeList.MakeModel addObject:mm];    
                [self.tableView reloadData];
            }
            break;  
        case fqsAircraftFeatures:
            switch (indexPath.row)
            {
                case afTailwheel:
                    self.fq.IsTailwheel.boolValue = !self.fq.IsTailwheel.boolValue;
                    break;
                case afHighPerf:
                    self.fq.IsHighPerformance.boolValue = !self.fq.IsHighPerformance.boolValue;
                    break;
                case afGlass:
                    self.fq.IsGlass.boolValue = !self.fq.IsGlass.boolValue;
                    break;
                case afTAA:
                    self.fq.IsTechnicallyAdvanced.boolValue = !self.fq.IsTechnicallyAdvanced.boolValue;
                    break;
                case afComplex:
                    self.fq.IsComplex.boolValue = !self.fq.IsComplex.boolValue;
                    break;
                case afRetract:
                    self.fq.IsRetract.boolValue = !self.fq.IsRetract.boolValue;
                    break;
                case afCSProp:
                    self.fq.IsConstantSpeedProp.boolValue = !self.fq.IsConstantSpeedProp.boolValue;
                    break;
                case afFlaps:
                    self.fq.HasFlaps.boolValue = !self.fq.HasFlaps.boolValue;
                    break;
                case afMotorGlider:
                    self.fq.IsMotorglider.boolValue = !self.fq.IsMotorglider.boolValue;
                    break;
                case afMultiEngineHeli:
                    self.fq.IsMultiEngineHeli.boolValue = !self.fq.IsMultiEngineHeli.boolValue;
                    break;
                case afEngineAny:
                    self.fq.EngineType = MFBWebServiceSvc_EngineTypeRestriction_AllEngines;
                    break;
                case afEngineJet:
                    self.fq.EngineType = MFBWebServiceSvc_EngineTypeRestriction_Jet;
                    break;
                case afEnginePiston:
                    self.fq.EngineType = MFBWebServiceSvc_EngineTypeRestriction_Piston;
                    break;
                case afEngineTurbine:
                    self.fq.EngineType = MFBWebServiceSvc_EngineTypeRestriction_AnyTurbine;
                   break;
                case afEngineElectric:
                    self.fq.EngineType = MFBWebServiceSvc_EngineTypeRestriction_Electric;
                    break;
                case afEngineTurboProp:
                    self.fq.EngineType = MFBWebServiceSvc_EngineTypeRestriction_Turboprop;
                    break;
                case afInstanceAny:
                    self.fq.AircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_AllAircraft;
                    break;
                case afInstanceReal:
                    self.fq.AircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_RealOnly;
                    break;
                case afInstanceTraining:
                    self.fq.AircraftInstanceTypes = MFBWebServiceSvc_AircraftInstanceRestriction_TrainingOnly;
                    break;                    
            }
            [self.tableView reloadData];
            break;
        case fqsProperties:
        {
            MFBWebServiceSvc_CustomPropertyType * cpt = (MFBWebServiceSvc_CustomPropertyType *)self.rgUsedProps[indexPath.row - 2];
            [self.fq togglePropertyType:cpt];
            [self.tableView reloadData];
            break;
        }
        case fqsFlightFeatures:
            switch (indexPath.row)
            {
                case ffActualIMC:
                    self.fq.HasIMC.boolValue = !self.fq.HasIMC.boolValue;
                    break;
                case ffApproaches:
                    self.fq.HasApproaches.boolValue = !self.fq.HasApproaches.boolValue;
                    break;
                case ffCFI:
                    self.fq.HasCFI.boolValue = !self.fq.HasCFI.boolValue;
                    break;
                case ffDual:
                    self.fq.HasDual.boolValue = !self.fq.HasDual.boolValue;
                    break;
                case ffFSLanding:
                    self.fq.HasFullStopLandings.boolValue = !self.fq.HasFullStopLandings.boolValue;
                    break;
                case ffFSNightLanding:
                    self.fq.HasNightLandings.boolValue = !self.fq.HasNightLandings.boolValue;
                    break;
                case ffAnyLandings:
                    self.fq.HasLandings.boolValue = !self.fq.HasLandings.boolValue;
                    break;
                case ffAnyInstrument:
                    self.fq.HasAnyInstrument.boolValue = !self.fq.HasAnyInstrument.boolValue;
                    break;
                case ffGroundSim:
                    self.fq.HasGroundSim.boolValue = !self.fq.HasGroundSim.boolValue;
                    break;
                case ffHold:
                    self.fq.HasHolds.boolValue = !self.fq.HasHolds.boolValue;
                    break;
                case ffIsPublic:
                    self.fq.IsPublic.boolValue = !self.fq.IsPublic.boolValue;
                    break;
                case ffNight:
                    self.fq.HasNight.boolValue = !self.fq.HasNight.boolValue;
                    break;
                case ffPIC:
                    self.fq.HasPIC.boolValue = !self.fq.HasPIC.boolValue;
                    break;
                case ffSIC:
                    self.fq.HasSIC.boolValue = !self.fq.HasSIC.boolValue;
                    break;
                case ffTotalTime:
                    self.fq.HasTotalTime.boolValue = !self.fq.HasTotalTime.boolValue;
                    break;
                case ffSimIMC:
                    self.fq.HasSimIMCTime.boolValue = !self.fq.HasSimIMCTime.boolValue;
                    break;
                case ffTelemetry:
                    self.fq.HasTelemetry.boolValue = !self.fq.HasTelemetry.boolValue;
                    break;
                case ffImages:
                    self.fq.HasImages.boolValue = !self.fq.HasImages.boolValue;
                    break;
                case ffXC:
                    self.fq.HasXC.boolValue = !self.fq.HasXC.boolValue;
                    break;
                case ffSigned:
                    self.fq.IsSigned.boolValue = !self.fq.IsSigned.boolValue;
                    break;
            }
            [self.tableView reloadData];
            break;
        case fqsNamedQueries:
            if (indexPath.row > 1) {
                self.fq = FlightQueryForm.rgCannedQueries[indexPath.row - 2];
                fSkipLoadText = YES;    // as we disappear, don't re-read from text cells - it can overwrite the saved query!
                [self.navigationController popViewControllerAnimated:YES];
            }
        default:
            break;
    }
}

#pragma mark DateRange Selector delegate
- (void) setStartDate:(NSDate *) s andEndDate:(NSDate *) e
{
    fq.DateRange = MFBWebServiceSvc_DateRanges_Custom;
    fq.DateMin = [MFBSoapCall UTCDateFromLocalDate:s];
    fq.DateMax = [MFBSoapCall UTCDateFromLocalDate:e];
    [self.tableView reloadData];
}

#pragma mark UITextFieldDelegate 
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loadText];
    return YES;
}
@end
