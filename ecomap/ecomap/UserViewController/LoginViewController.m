//
//  LoginViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapFetcher.h"
#import "EcomapUserFetcher.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation LoginViewController

#pragma mark - keyboard managment
//@override (to make allaway visible email and password textField)
//Called when the UIKeyboardDidShowNotification is sent
//To manage keyboard appearance (situation when keyboard cover active textField)
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //Increase scroll view contetn size by keyboard size
    CGRect contetntViewRect = self.activeField.superview.superview.frame;
    contetntViewRect.size.height += keyboardSize.height;
    self.scrollView.contentSize = contetntViewRect.size;
    
    // If password text field is hidden by keyboard, scroll it so it's visible
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    
    CGFloat passwordFieldHieght = self.passwordTextField.frame.size.height;
    CGPoint passwordFieldLeftBottomPoint = [self.view convertPoint:CGPointMake(self.passwordTextField.frame.origin.x, (self.passwordTextField.frame.origin.y + passwordFieldHieght))
                                                          fromView:self.passwordTextField.superview];
    
    if (!CGRectContainsPoint(visibleRect, passwordFieldLeftBottomPoint) ) {
        
        [self.scrollView setContentOffset:CGPointMake(0.0, self.scrollView.contentOffset.y + passwordFieldLeftBottomPoint.y - visibleRect.size.height + KEYBOARD_TO_TEXTFIELD_SPACE) animated:YES];
    }
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

#pragma mark - buttons
- (IBAction)loginButton:(UIButton *)sender {
    DDLogVerbose(@"Login on ecomap button pressed");
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if fields are empty
    if ([self isAnyTextFieldEmpty]) {
        [self showAlertViewWithTitile:@"Неповна інформація"
                           andMessage:@"\nБудь-ласка заповніть усі поля"];
        return;
    }
    
    //check if email is valid
    if (![self isValidMail:email]) {
        [self showAlertViewWithTitile:@"Помилка в email-адресі"
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
                 [self showCheckmarks:@[[NSNumber numberWithInt:checkmarkTypeEmail], [NSNumber numberWithInt:checkmarkTypePassword]] withImage:CHECKMARK_BAD_IMAGE];
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
