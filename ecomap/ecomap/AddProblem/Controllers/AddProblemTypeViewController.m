//
//  AddProblemTypeViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemTypeViewController.h"
#import "EcomapPathDefine.h"

@interface AddProblemTypeViewController ()

@property (nonatomic, strong) NSArray *problemTypes;

@end

@implementation AddProblemTypeViewController


- (float)viewHeight
{
    return 202.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.problemTypes = ECOMAP_PROBLEM_TYPES_ARRAY;
    [self.pickerView selectRow:6 inComponent:0 animated:NO];
}

#pragma mark - PickerView

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _problemTypes[row];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.problemTypes count];
}



@end
