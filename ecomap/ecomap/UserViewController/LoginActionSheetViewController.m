//
//  LoginActionSheetViewController.m
//  ecomap
//
//  Created by Vasilii Kotsiuba on 3/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginActionSheetViewController.h"

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

- (void)showActionSheetToLogin
{
    //        UIAlertView*  alertView = [[UIAlertView alloc] initWithTitle:@"Помилка" message:@"Незареєстровані користувачі на це не здатні.Зареєструйся!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //        [alertView show];
    //        UIAlertView *alertView = [[UIAlertView alloc]
    //                                  initWithTitle:@"DefaultStyle"
    //                                  message:@"the default alert view style"
    //                                  delegate:self
    //                                  cancelButtonTitle:@"Cancel"
    //                                  otherButtonTitles:@"OK", nil];
    //
    //        [alertView show];
    //Version 1: AlertView
    /*
     UIAlertController *alertController = [UIAlertController
     alertControllerWithTitle:@"DefaultStyle"
     message:@"the default alert view style"
     preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction *resetAction = [UIAlertAction
     actionWithTitle:NSLocalizedString(@"Reset", @"Reset action")
     style:UIAlertActionStyleDestructive
     handler:^(UIAlertAction *action)
     {
     NSLog(@"Reset action");
     }];
     
     UIAlertAction *cancelAction = [UIAlertAction
     actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
     style:UIAlertActionStyleCancel
     handler:^(UIAlertAction *action)
     {
     NSLog(@"Cancel action");
     }];
     
     UIAlertAction *okAction = [UIAlertAction
     actionWithTitle:NSLocalizedString(@"OK", @"OK action")
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction *action)
     {
     NSLog(@"OK action");
     }];
     
     [alertController addAction:resetAction];
     [alertController addAction:cancelAction];
     [alertController addAction:okAction];
     [self presentViewController:alertController animated:YES completion:nil];
     */
    
    
    //Version 2: action sheet
    //Create UIAlertController with ActionSheet style
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Ця дія потребує авторизації", @"Login alert title")
                                          //message:NSLocalizedString(@"Ця дія потребує авторизації", @"Login alert message")
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    //Create UIAlertAction's
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Відмінити", @"Cancel action on login alert")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *loginAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedString(@"Вхід", @"Login action on login alert")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      NSLog(@"Login action");
                                  }];
    
    UIAlertAction *loginWithFacebookAction = [UIAlertAction
                                              actionWithTitle:NSLocalizedString(@"Війти з Facebook", @"Loin with Facebook action on login alert")
                                              style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction *action)
                                              {
                                                  NSLog(@"loginWithFacebook action");
                                              }];
    
    //add actions to alertController
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    [alertController addAction:loginWithFacebookAction];
    
    //Present ActionSheet
    [self presentViewController:alertController animated:YES completion:nil];
    
    //For iPad popover presentation
    UIPopoverPresentationController *popover = alertController.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = sender;
        popover.sourceRect = sender.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }

}

//Notification aaction
- (void)didEnterBackground:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

//RemoveObserver
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

@end
