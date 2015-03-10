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

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerCellID];
    self.pickerCellRowHeight = pickerViewCellToCheck.frame.size.height;
}

#pragma mark - Properties

- (EcomapProblemFilteringMask *)filteringMask:(EcomapProblemFilteringMask *)filteringMask
{
    if(!_filteringMask) _filteringMask = [[EcomapProblemFilteringMask alloc] init];
    return _filteringMask;
}

#pragma mark - Helper Methods

- (BOOL)datePickerIsShown {
    
    return self.datePickerIndexPath != nil;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return numberOfSections;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat rowHeight = 44;
    
    if ([self datePickerIsShown] && (self.datePickerIndexPath.row == indexPath.row)) {
        rowHeight = self.pickerCellRowHeight;
    }
    
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row %ld, Section %ld", (long)indexPath.row, (long)indexPath.section);
    
    switch (indexPath.section) {
        case 0: return [self.tableView dequeueReusableCellWithIdentifier:kDateCellID];
        case 1: return [self.tableView dequeueReusableCellWithIdentifier:kProblemTypeCellID];
        case 2: return [self.tableView dequeueReusableCellWithIdentifier:kProblemStatusCellID];
    }
    
    return [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}



@end
