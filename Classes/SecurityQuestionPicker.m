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
//  SecurityQuestionPicker.m
//  MFBSample
//
//  Created by Eric Berman on 5/27/16.
//
//

#import "SecurityQuestionPicker.h"
#import "MFBAppDelegate.h"
#import "TextCell.h"

@interface SecurityQuestionPicker ()

@property (nonatomic, strong) NSArray * rgQuestions;
@end

@implementation SecurityQuestionPicker

@synthesize nuo, rgQuestions;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString * szQuestionList = NSLocalizedString(@"SecurityQuestions", @"Security Questions");
    self.rgQuestions = [szQuestionList componentsSeparatedByString:@"\n"];
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.rgQuestions = nil;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#define fontSize    16

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rgQuestions.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * sz = (NSString *) self.rgQuestions[indexPath.row];
    
    CGFloat h = [sz boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 20, 10000)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                                       context:nil].size.height;
    return ceil(h) + fontSize;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextCell * tc = [TextCell getTextCellTransparent:tableView];
    tc.txt.text = (NSString *) self.rgQuestions[indexPath.row];
    tc.txt.numberOfLines = 20;
    tc.txt.font = [UIFont systemFontOfSize:fontSize];
    tc.txt.adjustsFontSizeToFitWidth = NO;
    
    return tc;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.nuo.szQuestion = self.rgQuestions[indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
