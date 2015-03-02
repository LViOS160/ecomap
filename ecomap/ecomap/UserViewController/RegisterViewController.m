//
//  RegisterViewController.m
//  ecomap
//
//  Created by Gregory Chereda on 2/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//


#import "RegisterViewController.h"
//#import "EcomapFetcher.h"
#import "EcomapUserFetcher.h"
//Setup DDLog
#import "GlobalLoggerLevel.h"

typedef enum {oneIsEmpty, differentPasswords, smallLength, notEmail} Alerts; // types of showing alerts

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
    NSString *name = self.emailTextField.text;
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
    
    /*
    //Try to login (first effort). If not success, then try to register and login again
    [self loginWithEmail:email
             andPassword:password
            OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                if (!error && loggedUser) {
                    completionHandler (loggedUser, nil);
                } else {
                    // In case an error to login (first effort) has occured
                    //Try to register
                    [self registerWithName:name
                                andSurname:surname
                                  andEmail:email
                               andPassword:password
                              OnCompletion:^(NSError *error) {
                                  if (!error) {
                                      //Try to login (second effort)
                                      [self loginWithEmail:email
                                               andPassword:password
                                              OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                                  if (!error && loggedUser) {
                                                      completionHandler (loggedUser, nil);
                                                      //return;
                                                  } else {
                                                      // In case an error to login (second effort) has occured
                                                      completionHandler (nil, error);
                                                  }
                                              }]; //end of login (second effort) complition block
                                  } else {
                                      // In case an error to register has occured.
                                      completionHandler (nil, error);
                                  }
                              }];  //end of registartiom complition block
                }
            }]; //end of login (first effort) complition block
     */
}


// show the allerts in different cases
-(void)showTheUIRoutineAlert:(Alerts) alert{
    UIAlertView* alertView;
    
    switch(alert){
            
        case oneIsEmpty:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Please fill all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
        case differentPasswords:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Wrong confirmation" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
            
            
        case smallLength:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Password length is not secure" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
        case notEmail:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Email is not valid" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
            
    }
    
}


-(void)showhttpErrorAlert:(NSUInteger) error{
    UIAlertView* alertView;
    switch (error){
        case 0:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@" Registration is succesfull." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
        case 400:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@" This email has already existed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
        case 401:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Please, try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
        default:
            alertView = [[UIAlertView alloc] initWithTitle:@"Registration" message:@"Unknown error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            break;
    }
}

//- (IBAction)registerButton:(UIButton *)sender {
//    //__block
//    if (self.confirmText.text.length !=0 && self.passwordText.text.length!=0 && self.emailText.text.length!=0 && self.surnameText.text.length!=0 && self.nameText.text.length!=0){
//        if([self validateEmail:self.emailText.text])
//        {
//            if([self.confirmText.text isEqualToString:self.passwordText.text]){
//                if(self.passwordText.text.length > 4)
//                {
//                    [EcomapUserFetcher registerWithName:self.nameText.text
//                                         andSurname:self.surnameText.text
//                                           andEmail:self.emailText.text
//                                        andPassword:self.passwordText.text OnCompletion:^(NSError *error) {
//                                            NSInteger httpErrorCode = 0;
//                                            if(error) httpErrorCode = error.code;
//                                            [self showhttpErrorAlert:httpErrorCode];
//                                            if(httpErrorCode == 0){
//                                                [EcomapUserFetcher loginWithEmail:self.emailText.text andPassword:self.passwordText.text OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
//                                                    /*if(!error){
//                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Succesfull" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                                                        [alertView show];
//                                                    }*/
//                                                }
//                                                 ];
//                                            }
//
//                                            
//                                        }
//                     ];
//                }
//                else [self showTheUIRoutineAlert:smallLength];
//            }
//            else [self showTheUIRoutineAlert:differentPasswords];
//        }
//        else [self showTheUIRoutineAlert:notEmail];
//    }
//    else [self showTheUIRoutineAlert:oneIsEmpty];
//   
//}


@end
