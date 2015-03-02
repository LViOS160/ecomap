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
    [self spinerShouldShow:NO];
    [self.navigationController popViewControllerAnimated:YES];
    [self showAlertViewWithTitile:@""
                       andMessage:@"Ваш пароль змінено"];
    
    /*
    [EcomapUserFetcher registerWithName: name
                             andSurname: surname
                               andEmail: email
                            andPassword: password
                           OnCompletion:^(NSError *error) {
                               if (!error) {
                                   //Try to login
                                   [EcomapUserFetcher loginWithEmail: email
                                                         andPassword: password
                                                        OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                                            [self spinerShouldShow:NO];
                                                            if (!error && loggedUser) {
                                                                self.dismissBlock();
                                                                [self dismissViewControllerAnimated:YES completion:nil];
                                                                [self showAlertViewWithTitile:[NSString stringWithFormat:@"Вітаємо, %@!", loggedUser.name]
                                                                                   andMessage:@"\nЛаскаво просимо на Ecomap"];
                                                                
                                                            } else {
                                                                // In case an error to login has occured
                                                                [self showAlertViewWithTitile:@"Помилка"
                                                                                   andMessage:[error localizedDescription]];
                                                            }
                                                        }]; //end of login complition block
                               } else {
                                   // In case an error to register has occured.
                                   [self spinerShouldShow:NO];
                                   if (error.code == 400) {
                                       //Change checkmarks image
                                       [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail]] withImage:CHECKMARK_BAD_IMAGE];
                                       [self showAlertViewWithTitile:@"Помилка"
                                                          andMessage:@"Користувач з такою email-адресою вже зареєстрований"];
                                   } else {
                                       [self showAlertViewWithTitile:@"Помилка"
                                                          andMessage:[error localizedDescription]];
                                   }
                               }
                           }];  //end of registartiom complition block
     */
}

@end
