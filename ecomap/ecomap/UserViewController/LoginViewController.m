//
//  LoginViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginViewController.h"
#import "EcomapLoggedUser.h"
//#import "EcomapFetcher.h"
#import "EcomapUserFetcher.h"
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

//@override
//Check active text field (every time character is enetered) to set checkmark
-(void)editingChanged:(UITextField *)textField
{
    if (textField == self.emailTextField) {
        if ([self isValidMail:textField.text]) {
            [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail]] withImage:CHECKMARK_GOOD_IMAGE];
        } else [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail]] withImage:CHECKMARK_BAD_IMAGE];
    } else {
        if (![textField.text isEqualToString:@""]) {
            [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_GOOD_IMAGE];
        } else [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_BAD_IMAGE];
    }
}

#pragma mark - buttons
- (IBAction)loginButton:(UIButton *)sender {
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if fields are empty
    if ([self isAnyTextFieldEmpty]) {
        [self showAlertViewWithTitile:@"Помилка"
                           andMessage:@"\nБудь-ласка заповніть усі поля"];
        return;
    } else if (![self isValidMail:email]) { //check if email is valid
        [self showAlertViewWithTitile:@"Помилка"
                           andMessage:@"\nБудь-ласка введіть дійсну email-адресу"];
        return;
    }
    
    [self spinerShouldShow:YES];
    //Send e-mail and password on server
    [EcomapUserFetcher loginWithEmail:email andPassword:password OnCompletion:
     ^(EcomapLoggedUser *user, NSError *error){
         [self spinerShouldShow:NO];
         if (error){
             if (error.code == 400) {
                 //Change checkmarks image
                 [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail], [NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_BAD_IMAGE];
                 [self showAlertViewWithTitile:@"Помилка авторизації"
                                    andMessage:@"\nНеправильний пароль або email-адреса"];
             } else {
                 [self showAlertViewOfError:error];
             }
         }
         else{
             if (user) {
                 self.dismissBlock();
                 [self dismissViewControllerAnimated:YES completion:nil];
                 [self showAlertViewWithTitile:[NSString stringWithFormat:@"Вітаємо, %@!", user.name]
                                    andMessage:@"\nЛаскаво просимо на Ecomap"];
             } else {
                 [self showAlertViewWithTitile:@"Помилка на сервері"
                                    andMessage:@"\nЄ проблеми на сервері. Ми працюємо над їх вирішенням!"];
             }
             
         }
     }];
    
}
- (IBAction)loginWithFacebookButton:(id)sender {
    DDLogVerbose(@"Facebook button pressed");
    [self spinerShouldShow:YES];
    [EcomapUserFetcher loginWithFacebookOnCompletion:^(EcomapLoggedUser *loggedUserFB, NSError *error) {
        [self spinerShouldShow:NO];
        if (!error) {
            if (loggedUserFB) {
                self.dismissBlock();
                [self dismissViewControllerAnimated:YES completion:nil];
                [self showAlertViewWithTitile:[NSString stringWithFormat:@"Вітаємо, %@!", loggedUserFB.name]
                                   andMessage:@"\nЛаскаво просимо на Ecomap"];
            } else {
                [self showAlertViewWithTitile:@"Помилка входу через Facebook"
                                   andMessage:@"Неможливо отримати дані для авторизації на Ecomap"];
            }
            
        } else if (error.code == 400) {
            [self showAlertViewWithTitile:@"Помилка входу через Facebook"
                               andMessage:@"\nКористувач з такою email-адресою вже зареєстрований"];
        } else {
            [self showAlertViewWithTitile:@"Помилка входу через Facebook"
                               andMessage:[error localizedDescription]];
        }

        
    }];
    
}

- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
