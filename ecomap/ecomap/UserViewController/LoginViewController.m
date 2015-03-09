//
//  LoginViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapUserFetcher.h"
#import "RegisterViewController.h"
#import "LoginWithFacebook.h"
#import "InfoActions.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation LoginViewController

#pragma mark - accessors
//@override (to make allaway visible email and password textField)
-(UITextField *)textFieldToScrollUPWhenKeyboadAppears
{
    return self.passwordTextField;
}

#pragma mark - text field delegate
//@override
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField)
    {
        [textField resignFirstResponder];
        [self loginButton:nil];
    }
    return YES;
}

#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"register"]) {
        RegisterViewController *registerVC = segue.destinationViewController;
        registerVC.dismissBlock = self.dismissBlock;
    }
}

#pragma mark - buttons
- (IBAction)loginButton:(UIButton *)sender {
    DDLogVerbose(@"Login on ecomap button pressed");
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if fields are empty
    if ([self isAnyTextFieldEmpty]) {
        [InfoActions showAlertWithTitile:@"Неповна інформація"
                           andMessage:@"\nБудь-ласка заповніть усі поля"];
        return;
    } else if (![self isValidMail:email]) { //check if email is valid
        [InfoActions showAlertWithTitile:@"Помилка"
                              andMessage:@"\nБудь-ласка введіть дійсну email-адресу"];
        return;
    }
    
    //Change checkmarks image
    [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail], [NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_GOOD_IMAGE];
    
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    //Send e-mail and password on server
    [EcomapUserFetcher loginWithEmail:email andPassword:password OnCompletion:
     ^(EcomapLoggedUser *user, NSError *error){
         [InfoActions stopActivityIndicator];
         if (error){
             if (error.code == 400) {
                 //Change checkmarks image
                 [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail], [NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_BAD_IMAGE];
                 [InfoActions showAlertWithTitile:@"Помилка авторизації"
                                    andMessage:@"\nНеправильний пароль або email-адреса"];
             } else {
                 [InfoActions showAlertOfError:error];
             }
         }
         else{
             if (user) {
                 //perform dismissBlock before ViewController get off thе screen
                 self.dismissBlock(YES);
                 [self dismissViewControllerAnimated:YES completion:^{
                     //perform dismissBlock after ViewController get off thе screen
                     self.dismissBlock(NO);
                 }];
                 //show greeting for logged user
                 [InfoActions showAlertWithTitile:[NSString stringWithFormat:@"Вітаємо, %@!", user.name]
                                        andMessage:@"\nЛаскаво просимо на Ecomap"];
                 

             } else {
                 [InfoActions showAlertWithTitile:@"Помилка на сервері"
                                    andMessage:@"Є проблеми на сервері. Ми працюємо над їх вирішенням!"];
             }
             
         }
     }];
    
}
- (IBAction)loginWithFacebookButton:(id)sender {
    DDLogVerbose(@"Facebook button pressed");
    [LoginWithFacebook loginWithFacebook:^(BOOL result) {
        if (result) {
            //perform dismissBlock before ViewController get off thе screen
            self.dismissBlock(YES);
            
            [self dismissViewControllerAnimated:YES completion:^{
                //perform dismissBlock after ViewController get off thе screen
                self.dismissBlock(NO);
            }];
        }
    }];
}

- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
