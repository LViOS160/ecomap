//
//  RegisterViewController.m
//  ecomap
//
//  Created by Gregory Chereda on 2/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//


#import "RegisterViewController.h"

typedef enum {oneIsEmpty, differentPasswords, smallLength, notEmail} Alerts; // types of showing alerts


@interface RegisterViewController ()

@property (strong, nonatomic) IBOutlet UITextField *emailText;
@property (strong, nonatomic) IBOutlet UITextField *surnameText;
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *passwordText;
@property (strong, nonatomic) IBOutlet UITextField *confirmText;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

// show the allerts in different cases
-(void)showTheAlert:(Alerts) alert{
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

- (IBAction)registerButton:(UIButton *)sender {
    if (self.confirmText.text.length !=0 && self.passwordText.text.length!=0 && self.emailText.text.length!=0 && self.surnameText.text.length!=0 && self.nameText.text.length!=0){
        if([self validateEmail:self.emailText.text]){
            if([self.confirmText.text isEqualToString:self.passwordText.text]){
                if(self.passwordText.text.length > 4)
                {
                }
                else [self showTheAlert:smallLength];
            }
            else [self showTheAlert:differentPasswords];
        }
        else [self showTheAlert:notEmail];
    }
    else [self showTheAlert:oneIsEmpty];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
