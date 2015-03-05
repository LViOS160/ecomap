//
//  LoginActionSheetViewController.m
//  ecomap
//
//  Created by Vasilii Kotsiuba on 3/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginActionSheetViewController.h"
#import "LoginViewController.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@interface LoginActionSheetViewController ()

@end

@implementation LoginActionSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Add observer to listen when app enter background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                                object:nil];
}

- (void)showLogitActionSheetFromViewController:(UIViewController *)viewController sender:(id)sender actionAfterSuccseccLogin:(void (^)(void))dismissBlock
{
    UIView *senderView = nil;
    if ([sender isKindOfClass:[UIView class]]) {
        senderView = sender;
    }
    
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
                                   }];
    
    UIAlertAction *loginAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Вхід", @"Login action on login alert")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      DDLogVerbose(@"Login action");
                                      //[viewController prepareForSegue:<#(UIStoryboardSegue *)#> sender:<#(id)#>]
                                      [viewController performSegueWithIdentifier:@"login" sender:self];
                                      //Present viewController modaly
                                      //[viewController presentViewController:lvc animated:YES completion:nil];
                                  }];
    
    UIAlertAction *loginWithFacebookAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Війти з Facebook", @"Loin with Facebook action on login alert")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  DDLogVerbose(@"loginWithFacebook action");
                                              }];
    
    //add actions to alertController
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    [alertController addAction:loginWithFacebookAction];
    
    //Present ActionSheet
    [viewController presentViewController:alertController animated:YES completion:nil];
    
    //For iPad popover presentation
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = senderView;
        popover.sourceRect = senderView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }

}

//Notification aaction
- (void)didEnterBackground:(NSNotification *)notification
{
    DDLogVerbose(@"Dissmised action sheet when entered background");
    [self dismissViewControllerAnimated:NO completion:nil];
}

//RemoveObserver
-(void)dealloc
{
    DDLogVerbose(@"Dealoc actin sheet VC");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

@end
