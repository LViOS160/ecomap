//
//  ChangePasswordViewController.m
//  ecomap
//
//  Created by Vasya on 3/2/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapUserFetcher.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation ChangePasswordViewController
#pragma mark - text field delegate
//@override
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.oldPasswordTextField) {
        [self.passwordTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    } else if (textField == self.passwordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    } else if (textField == self.confirmPasswordTextField) {
        [textField resignFirstResponder];
        [self changePassworButton:nil];
    }
    return YES;
}


#pragma mark - buttons

- (IBAction)changePassworButton:(UIButton *)sender {
    DDLogVerbose(@"Change password button pressed");
    NSString *oldPasswod = self.oldPasswordTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if fields are empty
    if ([self isAnyTextFieldEmpty]) {
        [self showAlertViewWithTitile:@"Неповна інформація"
                           andMessage:@"\nБудь-ласка заповніть усі поля"];
        return;
    } else if (![self isPasswordsEqual]) //check if passwords are equal
    {
        [self showAlertViewWithTitile:@"Помилка"
                           andMessage:@"\nВведені паролі не співпадають"];
        return;
    }
    
    [self spinerShouldShow:YES];
    //Try to change password
    [EcomapUserFetcher changePassword:oldPasswod
                        toNewPassword:password
                         OnCompletion:^(NSError *error) {
                             [self spinerShouldShow:NO];
                             if (!error) {
                                 [self.navigationController popViewControllerAnimated:YES];
                                 [self showAlertViewWithTitile:@""
                                                    andMessage:@"Ваш пароль змінено"];
                             } else if (error.code == 400) {
                                 //Change checkmarks image
                                 [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_BAD_IMAGE];
                                 [self showAlertViewWithTitile:@"Помилка"
                                                    andMessage:@"\nВи ввели невірний пароль"];
                             } else {
                                 [self showAlertViewWithTitile:@"Помилка"
                                                    andMessage:[error localizedDescription]];
                             }
    
                             }];
}

@end
