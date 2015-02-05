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

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *loginText;

@property (strong, nonatomic) IBOutlet UITextField *passwordText;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customSetup];
}
- (IBAction)loginButton:(UIButton *)sender {
    NSString *login = self.loginText.text;
    NSString *password = self.passwordText.text;
    __block EcomapLoggedUser *loggedUser  = nil;
    
    [EcomapFetcher loginWithEmail:login andPassword:password OnCompletion:
     ^(EcomapLoggedUser *user, NSError *error){
         if (error){
             UIAlertView*  alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Incorrect password or email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alertView show];
         }
         else{
             UIAlertView*  alertView = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Succesfull" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [alertView show];
             loggedUser = user;
         }
     }
        ];
    //loggedUser
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customSetup
{
    EcomapRevealViewController *revealViewController = (EcomapRevealViewController *)self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
    
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
