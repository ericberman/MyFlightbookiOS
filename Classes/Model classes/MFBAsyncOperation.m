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
//  MFBAsyncOperation.m
//  MFBSample
//
//  Created by Eric Berman on 5/23/12.
//  Copyright (c) 2012-2017 MyFlightbook LLC. All rights reserved.
//

#import "MFBAsyncOperation.h"

@interface MFBAsyncOperation()
@property (readwrite, strong) id delegate;
@property (nonatomic, copy) void (^completionBlock)(MFBSoapCall *, MFBAsyncOperation *);
@end

@implementation MFBAsyncOperation

@synthesize delegate;
@synthesize completionBlock;

#pragma mark ObjectLifecycle
- (instancetype) init {
    self = [super init];
	if (self != nil)
    {
        self.delegate = nil;
        self.completionBlock = nil;
    }
    return self;
}


- (void) operationCompleted:(MFBSoapCall *)sc
{
    if (self.delegate != nil && self.completionBlock != nil)
        self.completionBlock(sc, self);
    self.delegate = nil;        // save memory by reducing an extra retain.
    self.completionBlock = nil; // also release the completion block to avoid a cycle
}

- (void) setDelegate:(id) o completionBlock:(void (^)(MFBSoapCall *, MFBAsyncOperation *)) compBlock
{
    self.delegate = o;
    self.completionBlock = compBlock;
}

@end
