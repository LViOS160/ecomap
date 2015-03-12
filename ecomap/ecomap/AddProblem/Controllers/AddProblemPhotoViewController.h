//
//  AddProblemPhotoViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstHeightViewController.h"

@interface AddProblemPhotoViewController : ConstHeightViewController

@property (nonatomic, assign) UIViewController *rootController;
@property (nonatomic, strong, readonly) NSArray *photos;

- (float)viewHeight;

@end
