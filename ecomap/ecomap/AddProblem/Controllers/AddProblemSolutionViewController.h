//
//  AppProblemSolutionViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstHeightViewController.h"

@interface AddProblemSolutionViewController : ConstHeightViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (float)viewHeight;

@end
