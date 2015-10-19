//
//  SlideAnimator.m
//  ecomap
//
//  Created by Anton Kovernik on 12.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "SlideAnimator.h"

@implementation SlideAnimator

#pragma mark - AddProblemAnimation

+ (void)slideViewFromRight:(ConstHeightViewController *)controller withPadding:(float)padding
{
    [SlideAnimator slideView:controller from:YES right:YES withPadding:padding];
}

+ (void)slideViewFromLeft:(ConstHeightViewController *)controller withPadding:(float)padding
{
    
    [SlideAnimator slideView:controller from:YES right:NO withPadding:padding];
}

+ (void)slideViewToRight:(ConstHeightViewController *)controller withPadding:(float)padding
{
    
    [SlideAnimator slideView:controller from:NO right:YES withPadding:padding];
}

+ (void)slideViewToLeft:(ConstHeightViewController *)controller withPadding:(float)padding
{
    [SlideAnimator slideView:controller from:NO right:NO withPadding:padding];
}


+ (void)slideView:(ConstHeightViewController*)controller from:(BOOL)from right:(BOOL)right withPadding:(float)padding
{
    CGRect rectOne;
    CGRect rectTwo;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    if (from)
    {             // slide from
        rectOne.origin.x = right ? screenWidth*2  : -screenWidth*2 ;
        rectTwo.origin.x = 0;
    }
    else
    {                // slide to
        rectOne.origin.x = 0;
        rectTwo.origin.x = right ? screenWidth : -screenWidth ;
    }
    
    rectOne.origin.y = [controller getPadding:padding];;
    rectOne.size.width = screenWidth;
    rectOne.size.height = controller.viewHeight;
    
    rectTwo.origin.y = [controller getPadding:padding];;
    rectTwo.size.width = rectOne.size.width;
    rectTwo.size.height = rectOne.size.height;
    
    [controller.view setFrame:rectOne];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         [controller.view setFrame:rectTwo];
                     }
                     completion:^(BOOL ok){
                         if (!from)[controller.view removeFromSuperview];
                     }];
}

@end
