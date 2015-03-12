//
//  AddProblemTypeViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 04.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConstHeightViewController.h"

@interface AddProblemTypeViewController : ConstHeightViewController

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

- (float)viewHeight;

@end
