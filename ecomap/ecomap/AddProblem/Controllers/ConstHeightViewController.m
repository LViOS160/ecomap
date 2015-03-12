//
//  ConstHeightViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 12.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ConstHeightViewController.h"

@implementation ConstHeightViewController

- (float)viewHeight {
    return 0.0f;
}

- (float)getPadding:(float)padding {
    
    return padding + ADDPROBLEMNAVIGATIONVIEWHEIGHT;
}

- (void)layoutView:(float)padding {
    [self.view setFrame:CGRectMake(0, [self getPadding:padding], [UIScreen mainScreen].bounds.size.width, self.viewHeight)];
}

@end
