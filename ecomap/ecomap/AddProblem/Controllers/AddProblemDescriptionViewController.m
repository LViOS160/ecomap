//
//  AddProblemDescriptionViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 03.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemDescriptionViewController.h"

@implementation AddProblemDescriptionViewController

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
    return 170.0;
}

@end
