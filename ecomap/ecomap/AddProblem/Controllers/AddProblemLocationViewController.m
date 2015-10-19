//
//  AddProblemLocationViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemLocationViewController.h"

@implementation AddProblemLocationViewController

- (IBAction)locateMeTap:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocateMeDidTap" object:self];
}

- (float)viewHeight
{
    return 137.0f;
}

@end
