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
#import "GlobalLoggerLevel.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *loginText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIView *containerViewFotTextFields;

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

    
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
//    self.scrollView.contentInset = contentInsets;
//    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    CGRect visibleRect = self.view.frame;
    visibleRect.size.height -= keyboardSize.height;
    CGFloat activeFieldHieght = self.activeField.frame.size.height;
    CGPoint activeFieldLeftBottomPoint = [self.view convertPoint:CGPointMake(self.activeField.frame.origin.x, (self.activeField.frame.origin.y + activeFieldHieght))
                                               fromView:self.activeField.superview];
    if (!CGRectContainsPoint(visibleRect, activeFieldLeftBottomPoint) ) {
        
        [self.scrollView setContentOffset:CGPointMake(0.0, self.scrollView.contentOffset.y + activeFieldLeftBottomPoint.y - visibleRect.size.height + KEYBOARD_TO_TEXTFIELD_SPACE) animated:YES];
        //[self.scrollView setContentOffset:CGPointMake(0.0, activeFieldOrigin.y - visibleRect.size.height + self.activeField.frame.size.height - self.navigationController.navigationBar.frame.size.height) animated:YES];
        //[scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y-kbSize.height) animated:YES];
        //[self.scrollView setContentOffset:CGPointMake(0.0, activeFieldOrigin.y - keyboardSize.height) animated:YES];
    }


    

    //[self.scrollView setContentOffset:CGPointMake(0.0, self.activeField.frame.origin.y+keyboardSize.height) animated:YES];
//
//    CGPoint buttonOrigin = self.signInButton.frame.origin;
//    
//    CGFloat buttonHeight = self.signInButton.frame.size.height;
//    
//    CGRect visibleRect = self.view.frame;
//    
//    visibleRect.size.height -= keyboardSize.height;
//    
//    if (!CGRectContainsPoint(visibleRect, buttonOrigin)){
//        
//        CGPoint scrollPoint = CGPointMake(0.0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
//        
//        [self.scrollView setContentOffset:scrollPoint animated:YES];
//        
//    }
}

#pragma mark - text field delegate
// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    //Decrease scroll view contetn size by keyboard size
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height -= keyboardSize.height;
    self.scrollView.contentSize = contentSize;
    NSLog(@"");
    
    //self.scrollView.contentOffset = CGPointZero;
    
    
//    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
//    scrollView.contentInset = contentInsets;
//    scrollView.scrollIndicatorInsets = contentInsets;
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
    NSString *login = self.loginText.text;
    NSString *password = self.passwordText.text;
    
    __block EcomapLoggedUser *loggedUser  = nil;
    
    [EcomapFetcher loginWithEmail:login andPassword:password OnCompletion:
     ^(EcomapLoggedUser *user, NSError *error){
         if (error){
            // int errorCode = error.code;
             UIAlertView*  alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Incorrect password or email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alertView show];
         }
         else{
             UIAlertView*  alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Succesfull" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alertView show];
             loggedUser = user;
             self.dismissBlock();
             [self dismissViewControllerAnimated:NO completion:nil];
             //[self performSegueWithIdentifier:@"ShowMap" sender:nil];
         }
     }
        ];
    //loggedUser
    
}

- (IBAction)cancelButton:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)touchUpinside:(UITapGestureRecognizer *)sender {
    [self.activeField resignFirstResponder];
    NSLog(@"Tap");
}



#pragma mark - helper methods

//Show error to the user in UIAlertView
- (void)showAlertViewOfError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Title"
                                                    message:[error localizedDescription]  //human-readable dwscription of the error
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
@end
