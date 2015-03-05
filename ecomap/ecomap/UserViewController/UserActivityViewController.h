//
//  UserActivityViewController.h
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

//This is base class for such user acivities classes: LoginViewController, RegisterViewControlle, ChangePasswordViewController, etc.
//It hold shared properties and methods.
//It is responsible for:
// - managing text fields editing (scroll up textField if it is hidden by keyboard). By defaults it checks active if "activeField" is hidden by keyboard. Set property "textFieldToScrollUPWhenKeyboadAppears" to change defaults behavior.
// - starting activityIndicator. Use "spinerShouldShow:" method (blocks user Interaction when spiner is active)
// - managing checkmarks behavior.
// - showing alert view
// - making e-mail validation, passwords comparison. Checks if any textField is empty.

#import <UIKit/UIKit.h>

@protocol UserAction <NSObject>
//What should be done after user action (login, logout, register, etc) ends success
@property (nonatomic, copy) void (^dismissBlock)(void);

@end

//checkmarkType number is equal to ckeckmarkImageView tag. On storyboard set appropriate tag to checkmark.
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

@interface UserActivityViewController : UIViewController <UITextFieldDelegate, UserAction>

//IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;  //on storyboard set tag equal to appropriate ckeckmarkImageView
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField; //on storyboard set tag equal to appropriate ckeckmarkImageView
@property (weak, nonatomic) IBOutlet UITextField *nameTextField; //on storyboard set tag equal to appropriate ckeckmarkImageView
@property (weak, nonatomic) IBOutlet UITextField *surnameTextField; //on storyboard set tag equal to appropriate ckeckmarkImageView
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField; //on storyboard set tag equal to appropriate ckeckmarkImageView
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTextField; //on storyboard set tag equal to appropriate ckeckmarkImageView
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorPad;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *checkmarks; //add all ckeckmarks here
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;  //add all textFields here

//Other priperties
@property(nonatomic, strong) UITextField *activeField; //currnet active textField.
@property(nonatomic, strong) UITextField *textFieldToScrollUPWhenKeyboadAppears; //set only to achieve another behavior
@property (nonatomic, copy) void (^dismissBlock)(void);

//Protected
//For subclasses
#pragma mark - keyborad managment
//To manage the situation when keyboard cover a textField. Should be called only if keyboard is already on screen, but you want to move to another textField
- (void)ifHiddenByKeyboarScrollUPTextField:(UITextField *)textFied;

#pragma mark - text field delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField; //Abstract

#pragma mark - helper methods
- (void)showAlertViewOfError:(NSError *)error;
- (void)showAlertViewWithTitile:(NSString *)title andMessage:(NSString *)message;
- (BOOL)isValidMail:(NSString *)checkString;
- (BOOL)isPasswordsEqual; //compare NewPasswordField and confirmPasswordField
- (BOOL)isAnyTextFieldEmpty;
- (void)spinerShouldShow:(BOOL)isVisible;
- (void)showCheckmarks:(NSArray *)checkmarkTypes withImage:(UIImage *)image; //changes checkmarks images

@end
