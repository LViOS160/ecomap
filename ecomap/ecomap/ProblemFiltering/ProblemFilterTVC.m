//
//  ProblemFilterTVC.m
//  ecomap
//
//  Created by ohuratc on 05.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProblemFilterTVC.h"
#import "EcomapPathDefine.h"
#import "EcomapProblemFilteringMask.h"

static NSInteger numberOfSections = 3;

static int kDatePickerTag = 101;
static int kProblemTypeImageTag = 102;
static int kTitleTag = 103;
static int kCheckboxImageTag = 104;

static NSString *kDateCellID = @"dateCell";
static NSString *kProblemTypeCellID = @"problemTypeCell";
static NSString *kProblemStatusCellID = @"problemStatusCell";
static NSString *kDatePickerCellID = @"datePickerCell";

@interface ProblemFilterTVC ()

@property (strong, nonatomic) EcomapProblemFilteringMask *filteringMask;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSIndexPath *datePickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;

@end

@implementation ProblemFilterTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

#pragma mark - Helper Methods

- (BOOL)datePickerIsShown {
    
    return self.datePickerIndexPath != nil;
}

- (UITableViewCell *)createDateCell:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
    
    return cell;
}

- (UITableViewCell *)createProblemTypeCell:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProblemTypeCellID];
    
    return cell;
}

- (UITableViewCell *)createProblemStatusCell:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kProblemStatusCellID];
    
    return cell;
}

- (UITableViewCell *)createPickerCell:(NSDate *)date
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    
    UIDatePicker *targetedDatePicker = (UIDatePicker *)[cell viewWithTag:kDatePickerTag];
    
    [targetedDatePicker setDate:date animated:NO];
    
    return cell;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat rowHeight = self.tableView.rowHeight;
    
    if ([self datePickerIsShown] && (self.datePickerIndexPath.row == indexPath.row)){
        
        rowHeight = self.pickerCellRowHeight;
        
    }
    
    return rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 2;
    
    switch(section) {
        case 0:
            if ([self datePickerIsShown]) numberOfRows++;
            return numberOfRows;
        case 1:
            return [ECOMAP_PROBLEM_TYPES_ARRAY count];
        case 2:
            return numberOfRows;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    switch(indexPath.section) {
        case 0: cell = [self createDateCell:indexPath];
        case 1: cell = [self createProblemTypeCell:indexPath];
        case 2: cell = [self createProblemStatusCell:indexPath];
    }
    
    return cell;
}



@end
