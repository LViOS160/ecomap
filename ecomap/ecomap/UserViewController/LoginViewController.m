//
//  LoginViewController.m
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginViewController.h"
#import "EcomapRevealViewController.h"
#import "EcomapLoggedUser.h"
#import "EcomapFetcher.h"
#import "EcomapUserFetcher.h"
#import "GlobalLoggerLevel.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *loginTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIView *activityIndicatorPad;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

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
#define KEYBOARD_TO_TEXTFIELD_SPACE 8.0
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
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
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //Reset scroll view contetn size by storyboard contentView size
    self.scrollView.contentSize = self.activeField.superview.superview.frame.size;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeField = nil;
}

#pragma mark - buttons
- (IBAction)loginButton:(UIButton *)sender {
    NSString *email = self.loginTextField.text;
    NSString *password = self.passwordTextField.text;
    
    //Check if fields are empty
    if ([email isEqualToString:@""] || [password isEqualToString:@""]) {
        [self showAlertViewWithTitile:@"Неповна інформація"
                           andMessage:@"\nБудь-ласка заповніть усі поля"];
        return;
    }
    
    //check if email is valid
    if (![self isValidMail:email]) {
        [self showAlertViewWithTitile:@"Помилка в пошті"
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

- (void)touchUpinside:(UITapGestureRecognizer *)sender {
    [self.activeField resignFirstResponder];
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

-(BOOL) isValidMail:(NSString *)checkString
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
@end
