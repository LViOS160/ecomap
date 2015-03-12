//
//  ProblemFilterTVC.h
//  ecomap
//
//  Created by ohuratc on 05.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
///

#import <UIKit/UIKit.h>
#import "EcomapProblemFilteringMask.h"

@interface ProblemFilterTVC : UITableViewController

@property (strong, nonatomic) EcomapProblemFilteringMask *filteringMask;

@end
