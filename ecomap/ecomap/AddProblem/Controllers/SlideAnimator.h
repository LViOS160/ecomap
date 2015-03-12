//
//  SlideAnimator.h
//  ecomap
//
//  Created by Anton Kovernik on 12.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstHeightViewController.h"

@interface SlideAnimator : NSObject

+ (void)slideViewFromRight:(ConstHeightViewController *)controller withPadding:(float)padding;
+ (void)slideViewFromLeft:(ConstHeightViewController *)controller withPadding:(float)padding;
+ (void)slideViewToRight:(ConstHeightViewController *)controller withPadding:(float)padding;
+ (void)slideViewToLeft:(ConstHeightViewController *)controller withPadding:(float)padding;

@end
