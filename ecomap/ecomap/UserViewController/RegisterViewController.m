//
//  RegisterViewController.m
//  ecomap
//
//  Created by Gregory Chereda on 2/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//


#import "RegisterViewController.h"
#import "LoginViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapUserFetcher.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"


@implementation RegisterViewController

#pragma mark - text field delegate
//@override
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        [self.surnameTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    } else if (textField == self.surnameTextField) {
        [self.emailTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    } else if (textField == self.passwordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
        [self ifHiddenByKeyboarScrollUPTextField:self.activeField];
    } else if (textField == self.confirmPasswordTextField)
    {
        [textField resignFirstResponder];
        [self registerButton:nil];
    }
    return YES;
}


#pragma mark - buttons


- (IBAction)registerButton:(UIButton *)sender {
    DDLogVerbose(@"Register on ecomap button pressed");
    NSString *name = self.nameTextField.text;
    NSString *surname = self.surnameTextField.text;
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if fields are empty
    if ([self isAnyTextFieldEmpty]) {
        [self showAlertViewWithTitile:@"Неповна інформація"
                           andMessage:@"\nБудь-ласка заповніть усі поля"];
        return;
    } else if (![self isValidMail:email]) { //check if email is valid
        [self showAlertViewWithTitile:@"Помилка"
                           andMessage:@"\nБудь-ласка введіть дійсну email-адресу"];
        return;
    } else if (![self isPasswordsEqual]) //check if passwords are equal
    {
        [self showAlertViewWithTitile:@"Помилка"
                           andMessage:@"\nВведені паролі не співпадають"];
        return;
    }
    
    [self spinerShouldShow:YES];
    //Try to register
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
}

@end
