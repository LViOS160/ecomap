//
//  AddProblemNameViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemNameViewController.h"

@implementation AddProblemNameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.problemName.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard
{
    [self.problemName resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}

- (float)viewHeight
{
    return 72.0f;
}

@end
