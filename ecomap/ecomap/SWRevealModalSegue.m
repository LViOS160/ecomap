//
//  SWRevealModalSegue.m
//  ecomap
//
//  Created by Vasilii Kotsiuba on 2/19/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "SWRevealModalSegue.h"
#import "SWRevealViewController.h"

@implementation SWRevealModalSegue

- (void)perform
{
    SWRevealViewController *rvc = [self.sourceViewController revealViewController];
    UIViewController *dvc = self.destinationViewController;
    [rvc presentViewController:dvc animated:YES completion:^{
        [rvc revealToggle:nil];
    }];
}

@end
