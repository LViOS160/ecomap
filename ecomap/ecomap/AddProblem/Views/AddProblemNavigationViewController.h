//
//  AddProblemNavigationViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 11.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddProblemNvatigationDelegate.h"
#import "ConstHeightViewController.h"

#import "Defines.h"

@interface AddProblemNavigationViewController : ConstHeightViewController

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *prevButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic, weak) id <AddProblemNvatigationDelegate> delegate;

- (float)viewHeight;

@end
