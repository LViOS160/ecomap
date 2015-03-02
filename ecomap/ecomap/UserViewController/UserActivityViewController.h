//
//  UserActivityViewController.h
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

//This is base class for such user acivities classes: LoginViewController, RegisterViewControlle, ChangePasswordViewController.
//It hold shared properties and methods

#import <UIKit/UIKit.h>

//checkmarkType number is equal to ckeckmarkImageView tag
typedef enum {
    checkmarkTypeName = 1,
    checkmarkTypeSurname = 2,
    checkmarkTypeEmail = 3,
    checkmarkTypePassword = 4,
    checkmarkTypeNewPassword = 5 //Common for NewPasswordField and confirmPasswordField
    
} checkmarkType;

#define CHECKMARK_GOOD_IMAGE [UIImage imageNamed:@"Good"]
#define CHECKMARK_BAD_IMAGE [UIImage imageNamed:@"Bad"]
#define KEYBOARD_TO_TEXTFIELD_SPACE 8.0

@interface UserActivityViewController : UIViewController <UITextFieldDelegate>


@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *surnameTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorPad;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *checkmarks;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;

//Protected
//For subclasses
#pragma mark - keyborad managment
//To manage keyboard appearance (situation when keyboard cover active textField)
- (void)keyboardWasShown:(NSNotification*)aNotification;

#pragma mark - text field delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField; //Abstract

#pragma mark - helper methods
- (void)showAlertViewOfError:(NSError *)error;
- (void)showAlertViewWithTitile:(NSString *)title andMessage:(NSString *)message;
- (BOOL)isValidMail:(NSString *)checkString;
- (BOOL)isPasswordsEqual;
- (BOOL)isAnyTextFieldEmpty;
- (void)spinerShouldShow:(BOOL)isVisible;
- (void)showCheckmarks:(NSArray *)checkmarkTypes withImage:(UIImage *)image;

@end
