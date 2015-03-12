//
//  AddProblemDescriptionViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 03.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstHeightViewController.h"
#import "Defines.h"

@interface AddProblemDescriptionViewController : ConstHeightViewController <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

- (float)viewHeight;

@end
