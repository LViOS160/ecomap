//
//  ProfileViewController.m
//  ecomap
//
//  Created by Vasilii Kotsiuba on 2/23/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProfileViewController.h"
#import "EcomapFetcher.h"
#import "EcomapUserFetcher.h"
#import "EcomapLoggedUser.h"
#import "GlobalLoggerLevel.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *surmaneLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePicture;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgProfilePicture.layer.masksToBounds = YES;
    self.imgProfilePicture.layer.cornerRadius = 30.0;
    self.imgProfilePicture.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imgProfilePicture.layer.borderWidth = 1.0;
    [self prepareLabels];
    // Do any additional setup after loading the view.
}

- (void)prepareLabels
{
    EcomapLoggedUser *user = [EcomapLoggedUser currentLoggedUser];
    self.nameLabel.text = user.name ? user.name : @"";
    self.surmaneLabel.text = user.surname ? user.surname : @"";
    self.roleLabel.text = user.role ? user.role : @"";
    self.emailLabel.text = user.email ? user.email : @"";
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)closeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)LogoutButton:(id)sender {
    [EcomapUserFetcher logoutUser:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(BOOL result, NSError *error) {
        if (!error) {
            if(result) DDLogVerbose(@"Logout button result: %d", result);
        }
    }];
    self.dismissBlock();
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
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
    
    CGFloat passwordFieldHieght = self.passwordText.frame.size.height;
    CGPoint passwordFieldLeftBottomPoint = [self.view convertPoint:CGPointMake(self.passwordText.frame.origin.x, (self.passwordText.frame.origin.y + passwordFieldHieght))
                                                          fromView:self.passwordText.superview];
    //CGFloat activeFieldHieght = self.activeField.frame.size.height;
    //CGPoint activeFieldLeftBottomPoint = [self.view convertPoint:CGPointMake(self.activeField.frame.origin.x, (self.activeField.frame.origin.y + activeFieldHieght))
    //                                          fromView:self.activeField.superview];
    //if (!CGRectContainsPoint(visibleRect, activeFieldLeftBottomPoint) ) {
    if (!CGRectContainsPoint(visibleRect, passwordFieldLeftBottomPoint) ) {
        
        [self.scrollView setContentOffset:CGPointMake(0.0, self.scrollView.contentOffset.y + passwordFieldLeftBottomPoint.y - visibleRect.size.height + KEYBOARD_TO_TEXTFIELD_SPACE) animated:YES];
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
 */

@end
