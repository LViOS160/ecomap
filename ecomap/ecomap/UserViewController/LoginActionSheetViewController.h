//
//  LoginActionSheetViewController.h
//  ecomap
//
//  Created by Vasilii Kotsiuba on 3/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginActionSheetViewController : UIViewController
//Sender can be nill. It is required for iPad to present popover in right position (since action sheet is presented in popover on iPad)
//dismissBlock can be nill. Set it if you need some action to be done after success login.
- (void)showLogitActionSheetFromViewController:(UIViewController *)viewController sender:(id)sender actionAfterSuccseccLogin:(void (^)(void))dismissBlock;
@end
