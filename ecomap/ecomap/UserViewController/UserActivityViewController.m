//
//  UserActivityViewController.m
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "UserActivityViewController.h"

@implementation UserActivityViewController

#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Set gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchUpinside:)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //setup keyboard notifications
    [self registerForKeyboardNotifications];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.activeField resignFirstResponder];
    [self deregisterForKeyboardNotifications];
}

#pragma mark - keyborad managment
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

// Called when the UIKeyboardDidShowNotification is sent
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

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //Reset scroll view contetn size by storyboard contentView size
    self.scrollView.contentSize = self.activeField.superview.superview.frame.size;
}

//Manage tap gesture
- (void)touchUpinside:(UITapGestureRecognizer *)sender {
    [self.activeField resignFirstResponder];
}

#pragma mark - text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
    //Set target action fot textField
    [self.activeField addTarget:self
                         action:@selector(editingChanged:)
               forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField //Abstract
{
    return YES;
}

//Check active text field (every time character is enetered) to set checkmark
-(void)editingChanged:(UITextField *)textField
{
    //consider "taxtField.tag" value is equal to appropriative checkmarkType value
    
    if ((textField.tag == checkmarkTypeEmail && [self isValidMail:textField.text]) ||  //validation for email
        (textField.tag == checkmarkTypeNewPassword && [self isPasswordsEqual]) || //validation for passwords (newPassword and confirdPasswor)
        ([self isTypeOfSimpleTextOfTextField:textField] && ![textField.text isEqualToString:@""])) { //validation for name, surname, oldPassword
        [self showCheckmarks:@[[NSNumber numberWithInt:textField.tag]] withImage:CHECKMARK_GOOD_IMAGE];
    } else {
        [self showCheckmarks:@[[NSNumber numberWithInt:textField.tag]] withImage:CHECKMARK_BAD_IMAGE];
    }
}

#pragma mark - helper methods
- (void)showAlertViewOfError:(NSError *)error
{
    [self showAlertViewWithTitile:@"Помилка"
                       andMessage:[error localizedDescription]]; //human-readable dwscription of the error
}

- (void)showAlertViewWithTitile:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(BOOL)isValidMail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    //Uncomment on release
    //NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *laxString = @".+@.+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)isPasswordsEqual {
    BOOL equal = NO;
    if ([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text] && ![self.passwordTextField.text isEqualToString:@""]) {
        equal = YES;
    }
    return equal;
}

//Consider name, surname and password field are "simple text" text fields (because the only validation for them is not to be empty field)
- (BOOL)isTypeOfSimpleTextOfTextField:(UITextField *)textField{
    BOOL simple = NO;
    if (textField.tag == checkmarkTypeName || textField.tag == checkmarkTypeSurname || textField.tag == checkmarkTypePassword) {
        simple = YES;
    }
    return simple;
}

-(BOOL)isAnyTextFieldEmpty
{
    BOOL empty = NO;
    for (UITextField *textField in self.textFields) {
        if ([textField.text isEqualToString:@""]) {
            empty = YES;
            break;
        }
    }
    
    return empty;
}

- (void)spinerShouldShow:(BOOL)isVisible
{
    if (isVisible) {
        //Disable touches on screen
        self.view.userInteractionEnabled = NO;
        
        //Show spiner
        [self.activityIndicator startAnimating];
        self.activityIndicatorPad.hidden = NO;
        self.activityIndicator.hidden = NO;
    } else {
        //Enable touches on screen
        self.view.userInteractionEnabled = YES;
        
        //Show spiner
        self.activityIndicatorPad.hidden = YES;
        self.activityIndicator.hidden = YES;
        [self.activityIndicator startAnimating];
    }
}

- (void)showCheckmarks:(NSArray *)checkmarkTypes withImage:(UIImage *)image
{
    for (UIImageView *imageView in self.checkmarks) {
        for (NSNumber *number in checkmarkTypes) {
            if (imageView.tag == [number integerValue]) {
                imageView.alpha = 1.0;
                imageView.image = image;
            }
        }
        
    }
}

@end
