//
//  InfoActions.m
//  ecomap
//
//  Created by Vasya on 3/7/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "InfoActions.h"
#import "EcomapUserFetcher.h"
#import "UIViewController+Utils.h"
#import "LoginViewController.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation InfoActions

+ (void)showAlertViewWithTitile:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Login action sheet
+ (void)showLogitActionSheetFromSender:(id)sender actionAfterSuccseccLogin:(void (^)(void))dismissBlock
{
    
    UIView *senderView = nil;
    if ([sender isKindOfClass:[UIView class]]) {
        senderView = sender;
    }
    
    //Get current ViewControlller
    UIViewController *currentVC = [UIViewController currentViewController];
    
    //Create UIAlertController with ActionSheet style
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Ця дія потребує авторизації", @"Login alert title")
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    //Create UIAlertAction's
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Відмінити", @"Cancel action on login alert")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       DDLogVerbose(@"Cancel action");
                                       [self showPopupWithMesssage:@"Canceled"];
                                   }];
    
    UIAlertAction *loginAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Вхід", @"Login action on login alert")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      DDLogVerbose(@"Login button on action sheet pressed");
                                      
                                      //Load LoginViewController from storyboard
                                      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                      UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
                                      
                                      //Get pointer to LoginViewController
                                      LoginViewController *loginVC = (LoginViewController *)[navController topViewController];
                                      
                                      //setup LoginViewController
                                      loginVC.showGreetingAfterLogin = NO;
                                      loginVC.dismissBlock = ^(BOOL isUserActionViewControllerOnScreen){
                                          if (!isUserActionViewControllerOnScreen) {
                                              dismissBlock();
                                          }
                                      };
                                      
                                      //Present modaly LoginViewController
                                      [currentVC presentViewController:navController animated:YES completion:nil];
                                  }];
    
    UIAlertAction *loginWithFacebookAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Війти з Facebook", @"Loin with Facebook action on login alert")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  DDLogVerbose(@"loginWithFacebook action");
                                                  [EcomapUserFetcher loginWithFacebookOnCompletion:^(EcomapLoggedUser *loggedUserFB, NSError *error) {
                                                  }];
                                                  dismissBlock();
                                              }];
    
    //add actions to alertController
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    [alertController addAction:loginWithFacebookAction];
    
    //Present ActionSheet
    [currentVC presentViewController:alertController animated:YES completion:nil];
    
    //For iPad popover presentation
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = senderView;
        popover.sourceRect = senderView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
}

#pragma mark - Popup
#define POPUP_DELAY  1.5
+ (void)showPopupWithMesssage:(NSString *)message
{
    if ([message isEqualToString:@""]) {
        DDLogError(@"Can't show popup with no text");
        return;
    }
    
    //Create popup label
    UILabel *popupLabel = [self createLabelWithText:message];
    
    //Get keyWindos
    UIWindow *appKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    //Position in center
    popupLabel.center = [appKeyWindow center];
    
    //show popup
    [appKeyWindow addSubview:popupLabel];
    DDLogVerbose(@"Popup showed");
    
    //Appear animation
    popupLabel.transform = CGAffineTransformMakeScale(1.3, 1.3);
    popupLabel.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        popupLabel.alpha = 1;
        popupLabel.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    //Dismiss popup after delay
    [self performSelector:@selector(dismissPopup:) withObject:popupLabel afterDelay:POPUP_DELAY];
}

+ (void)dismissPopup:(UIView *)sender {
    // Fade out the message and destroy popup
    [UIView animateWithDuration:0.3
                     animations:^  {
                         sender.transform = CGAffineTransformMakeScale(1.3, 1.3);
                         sender.alpha = 0; }
                     completion:^ (BOOL finished) {
                         DDLogVerbose(@"Popup dismissed");
                         [sender removeFromSuperview];
                     }];
}

+ createLabelWithText:(NSString *)message
{
    UILabel *popupLabel = [[UILabel alloc] init];
    //Set text
    popupLabel.text = message;
    
    popupLabel.textAlignment = NSTextAlignmentCenter;
    popupLabel.numberOfLines = 2;
    
    //Set frame
    CGFloat textWidth = popupLabel.intrinsicContentSize.width;
    popupLabel.frame = CGRectMake(0, 0, textWidth + 20, 50);
    
    //Set color
    popupLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    popupLabel.textColor = [UIColor whiteColor];
    
    //Make rounded rect
    popupLabel.layer.cornerRadius = 5.0;
    popupLabel.clipsToBounds=YES;
    
    return popupLabel;
}

@end
