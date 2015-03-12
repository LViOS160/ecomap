//
//  ConstHeightViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 12.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"

@interface ConstHeightViewController : UIViewController

- (float)getPadding:(float)padding;
- (float)viewHeight;
- (void)layoutView:(float)padding;

@end
