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
#import "LoginWithFacebook.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@interface InfoActions ()
@property (nonatomic, strong) UIView *activityIndicatorView;
@property (nonatomic, strong) UILabel *popupLabel;
@property (nonatomic, strong) NSMutableArray *popupLabels; //Of UILabels
@property (nonatomic) BOOL userInteraction;
@end

@implementation InfoActions

#pragma mark - Singleton
+ (instancetype)sharedActions
{
    
    static InfoActions *sharedActions = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedActions = [[InfoActions alloc] init];
        
        if (sharedActions) {
            //Register observer to receive notifications
            
            //Add observer to listen when device chages orientation
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:sharedActions
                   selector:@selector(orientationChanged:)
                       name:UIDeviceOrientationDidChangeNotification
                     object:nil];
        }
        
    });
    
    return sharedActions;
    
}

//Center all action views here
- (void)orientationChanged:(NSNotification *)note
{
    CGPoint center = [[UIApplication sharedApplication] keyWindow].center;
    self.activityIndicatorView.center = center;
    self.popupLabel.center = center;
}

#pragma mark - Alets

+ (void)showAlertWithTitile:(NSString *)title andMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"Cancel button title on alert")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertController addAction:cancelAction];
    
    //Get current ViewControlller
    UIViewController *currentVC = [UIViewController currentViewController];
    
    //Present Alert
    [currentVC presentViewController:alertController animated:YES completion:nil];
}
 
+ (void)showAlertOfError:(id)error
{
    NSString *errorMessage = nil;
    if ([error isKindOfClass:[NSError class]]) {
        errorMessage = [error localizedDescription]; //human-readable dwscription of the error
    } else if ([error isKindOfClass:[NSString class]]) {
        errorMessage = (NSString *)error;
    } else errorMessage = @"";
        
    [self showAlertWithTitile:NSLocalizedString(@"Помилка", @"Error title")
                        andMessage:errorMessage];
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
                                          alertControllerWithTitle:NSLocalizedString(@"Ця дія потребує авторизації", @"Login actionSheet title: This action requires authorization")
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    //Create UIAlertAction's
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Відмінити", @"Cancel button title on login actionSheet")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       DDLogVerbose(@"Cancel action");;
                                   }];
    
    UIAlertAction *loginAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Вхід", @"Login button title on login actionSheet")
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
                                      loginVC.dismissBlock = ^(BOOL isUserActionViewControllerOnScreen){
                                          if (!isUserActionViewControllerOnScreen) {
                                              dismissBlock();
                                          }
                                      };
                                      
                                      //Present modaly LoginViewController
                                      [currentVC presentViewController:navController animated:YES completion:nil];
                                      
                                  }]; //end of UIAlertAction handler block
    
    UIAlertAction *loginWithFacebookAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Війти з Facebook", @"Loin with Facebook button title on login actionSheet")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  DDLogVerbose(@"loginWithFacebook action");
                                                  [LoginWithFacebook loginWithFacebook:^(BOOL result) {
                                                      if (result) {
                                                          //perform dismissBlock
                                                          dismissBlock();
                                                      }

                                                  }]; //end of LoginWithFacebook block
                                                  
                                              }]; //end of UIAlertAction handler block
    
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
    
    InfoActions *sharedActions = [self sharedActions];
    
    //Create popup label
    sharedActions.popupLabel = [self createLabelWithText:message];
    
    //Get keyWindos
    UIWindow *appKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    [sharedActions.popupLabels addObject:[self createLabelWithText:message]];
    
//    for (UILabel *popupLabel in sharedActions.popupLabels){
//        popupLabel.center = appKeyWindow.center
//    }
    
    //Position in center
    sharedActions.popupLabel.center = [appKeyWindow center];
    
    //show popup
    [appKeyWindow addSubview:sharedActions.popupLabel];
    DDLogVerbose(@"Popup showed");
    
    //Appear animation
    sharedActions.popupLabel.transform = CGAffineTransformMakeScale(1.3, 1.3);
    sharedActions.popupLabel.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        sharedActions.popupLabel.alpha = 1;
        sharedActions.popupLabel.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
    //Dismiss popup after delay
    [self performSelector:@selector(dismissPopup:) withObject:sharedActions.popupLabel afterDelay:POPUP_DELAY];
}

+ (void)dismissPopup:(UIView *)sender {
    
    InfoActions *sharedActions = [self sharedActions];
    __block UILabel *label = (UILabel *)sender;
    // Fade out the message and destroy popup
    [UIView animateWithDuration:0.3
                     animations:^  {
                         label.transform = CGAffineTransformMakeScale(1.3, 1.3);
                         label.alpha = 0; }
                     completion:^ (BOOL finished) {
                         label = nil;
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
    CGRect labelFrame = CGRectMake(0, 0, textWidth + 20, 50);
    
    //To make popup not to be wider tan 170 points
    if (textWidth > 170) {
        labelFrame = [popupLabel textRectForBounds:CGRectMake(0, 0, 170, 50)
                            limitedToNumberOfLines:2];
    }
    
    popupLabel.frame = labelFrame;
    
    //Set color
    popupLabel.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    popupLabel.textColor = [UIColor whiteColor];
    
    //Make rounded rect
    popupLabel.layer.cornerRadius = 5.0;
    popupLabel.clipsToBounds=YES;
    
    return popupLabel;
}

#pragma mark - Activity Indicator
+ (void)startActivityIndicatorWithUserInteractionEnabled:(BOOL)enabled
{
    
    InfoActions *sharedActions = [self sharedActions];
    
    if (sharedActions.activityIndicatorView) {
        DDLogError(@"Can't create 2-nd activity indicator");
        return;
    }
    
    //Get keyWindos
    UIWindow *appKeyWindow = [[UIApplication sharedApplication] keyWindow];
    
    sharedActions.userInteraction = enabled;
    if (!enabled) {
        //Disable user events handling
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }
    
    //Create activity indicator transparent black pad
    sharedActions.activityIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    sharedActions.activityIndicatorView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    sharedActions.activityIndicatorView.layer.cornerRadius = 5.0;
    sharedActions.activityIndicatorView.clipsToBounds=YES;
    //Position in center
    sharedActions.activityIndicatorView.center = appKeyWindow.center;
    //add to view hierarchy
    [appKeyWindow addSubview:sharedActions.activityIndicatorView];
    
    //Create activity indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    activityIndicator.center = CGPointMake(sharedActions.activityIndicatorView.bounds.size.width / 2, sharedActions.activityIndicatorView.bounds.size.height / 2);
    //add to view activityIndicatorPad
    [sharedActions.activityIndicatorView addSubview:activityIndicator];
    
    DDLogVerbose(@"Activity indicator started");
    
    //Show dismiss button after delay (so user can cancel activity indicator in case of some error)
    //[self performSelector:@selector(showDismissButton:) withObject:nil afterDelay:20];
    
}

+ (void)stopActivityIndicator
{
    InfoActions *sharedActions = [self sharedActions];
    
    if (sharedActions.activityIndicatorView) {
        [sharedActions.activityIndicatorView removeFromSuperview];
        
        //Enable user events handling
        if (!sharedActions.userInteraction) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
        
        sharedActions.activityIndicatorView = nil;
        
        DDLogVerbose(@"Activity indicator stoped");
    }
}

@end
