//
//  AppProblemSolutionViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemSolutionViewController.h"

@implementation AddProblemSolutionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [self.textView resignFirstResponder];
}

- (float)viewHeight {
    return 170.0f;
}

@end
