//
//  ProfileViewController.m
//  ecomap
//
//  Created by Vasilii Kotsiuba on 2/23/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "ProfileViewController.h"
#import "EcomapFetcher.h"
#import "EcomapLoggedUser.h"
#import "GlobalLoggerLevel.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *surmaneLabel;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [EcomapFetcher logoutUser:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(BOOL result, NSError *error) {
        if (!error) {
            if(result) DDLogVerbose(@"%d", result);
        }
    }];
    self.dismissBlock();
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
