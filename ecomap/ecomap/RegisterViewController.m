//
//  RegisterViewController.m
//  ecomap
//
//  Created by Gregory Chereda on 2/5/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//


#import "RegisterViewController.h"
#import "EcomapFetcher.h"

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

- (IBAction)registerButton:(UIButton *)sender {
    //__block
    if (self.confirmText.text.length !=0 && self.passwordText.text.length!=0 && self.emailText.text.length!=0 && self.surnameText.text.length!=0 && self.nameText.text.length!=0){
        if(true)//[self validateEmail:self.emailText.text])
        {
            if([self.confirmText.text isEqualToString:self.passwordText.text]){
                if(self.passwordText.text.length > 4)
                {
                    [EcomapFetcher registerWithName:self.nameText.text
                                         andSurname:self.surnameText.text
                                           andEmail:self.emailText.text
                                        andPassword:self.passwordText.text OnCompletion:^(NSError *error) {
                                            NSInteger httpErrorCode = 0;
                                            if(error) httpErrorCode = error.code;
                                            [self showhttpErrorAlert:httpErrorCode];
                                            if(httpErrorCode == 0){
                                                [EcomapFetcher loginWithEmail:self.emailText.text andPassword:self.passwordText.text OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                                    if(!error){
                                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Succesfull" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                        [alertView show];
                                                    }
                                                }
                                                 ];
                                            }

                                            
                                        }
                     ];
                }
                else [self showTheUIRoutineAlert:smallLength];
            }
            else [self showTheUIRoutineAlert:differentPasswords];
        }
        else [self showTheUIRoutineAlert:notEmail];
    }
    else [self showTheUIRoutineAlert:oneIsEmpty];
   
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
