//
//  AddProblemNavigationViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 11.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "AddProblemNavigationViewController.h"

@interface AddProblemNavigationViewController ()

@end

@implementation AddProblemNavigationViewController

- (IBAction)prevButton:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(prevPage)]) {
        [self.delegate prevPage];
    }
}

- (IBAction)nextButton:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nextPage)]) {
        [self.delegate nextPage];
    }
}

- (float)viewHeight {
    return ADDPROBLEMNAVIGATIONVIEWHEIGHT;
}

- (float)getPadding:(float)padding {
    return padding;
}





@end
