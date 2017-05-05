/*
	MyFlightbook for iOS - provides native access to MyFlightbook
	pilot's logbook
 Copyright (C) 2017 MyFlightbook, LLC
 
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
//  AccessoryBar.m
//  MFBSample
//
//  Created by Eric Berman on 3/5/13.
//
//

#import "AccessoryBar.h"

@interface AccessoryBar()
@property (nonatomic, strong) id<AccessoryBarDelegate> abDelegate;
@end

@implementation AccessoryBar
@synthesize btnDelete, btnDone, btnNext, btnPrev, abDelegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark AccessoryBarDelegate methods
- (void) nextClicked
{
    [self.abDelegate nextClicked];
}

- (void) prevClicked
{
    [self.abDelegate prevClicked];
}

- (void) doneClicked
{
    [self.abDelegate doneClicked];
}

- (void) deleteClicked
{
    [self.abDelegate deleteClicked];
}

#pragma mark LifeCycle
- (void) dealloc
{
    self.delegate = nil;
}

+ (AccessoryBar *) getAccessoryBar:(id<AccessoryBarDelegate>)d
{
    NSArray * ar = [[NSBundle mainBundle] loadNibNamed:@"AccessoryBar" owner:self options:nil];
    for (id object in ar)
    if ([object isKindOfClass:[AccessoryBar class]])
    {
        AccessoryBar * ab = (AccessoryBar *) object;
        ab.abDelegate = d;
        return ab;
    }
    return nil;
}


@end
