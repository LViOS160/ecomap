//
//  RegisterViewController.m
//  ecomap
//
//  Created by Gregory Chereda on 2/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//


#import "RegisterViewController.h"
#import "EcomapFetcher.h"
#import "EcomapUserFetcher.h"

typedef enum {oneIsEmpty, differentPasswords, smallLength, notEmail} Alerts; // types of showing alerts

@implementation RegisterViewController

#pragma mark - text field delegate
//@override
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        [self.surnameTextField becomeFirstResponder];
    } else if (textField == self.surnameTextField) {
        [self.emailTextField becomeFirstResponder];
    } else if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.confirmPasswordTextField becomeFirstResponder];
    } else if (textField == self.confirmPasswordTextField)
    {
        [textField resignFirstResponder];
        //[self registerButton:nil];
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
    } else if (textField == self.passwordTextField || textField == self.confirmPasswordTextField){
        if ([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text] && ![self.passwordTextField.text isEqualToString:@""]) {
            [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypePassword], [NSNumber numberWithInt:checkmarkTypeConfirmPassword]] withImage:CHECKMARK_GOOD_IMAGE];
        } else [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypePassword], [NSNumber numberWithInt:checkmarkTypeConfirmPassword]] withImage:CHECKMARK_BAD_IMAGE];
    } else if (textField == self.nameTextField) {
        if (![textField.text isEqualToString:@""]) {
            [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypeName]] withImage:CHECKMARK_GOOD_IMAGE];
        } else [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypeName]] withImage:CHECKMARK_BAD_IMAGE];
    } else if (textField == self.surnameTextField) {
        if (![textField.text isEqualToString:@""]) {
            [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypeSurname]] withImage:CHECKMARK_GOOD_IMAGE];
        } else [self shouldShow:YES checkmarks:@[[NSNumber numberWithInt:checkmarkTypeSurname]] withImage:CHECKMARK_BAD_IMAGE];
    }
}

#pragma mark - buttons

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
