//
//  VasylKorsiubaViewControllerForTestsViewController.m
//  ecomap
//
//  Created by Vasya on 2/10/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "VasylKorsiubaViewControllerForTestsViewController.h"
#import "EcomapFetcher.h"
#import "EcomapLoggedUser.h"
#import "EcomapProblemDetails.h"

@interface VasylKorsiubaViewControllerForTestsViewController ()

@end

@implementation VasylKorsiubaViewControllerForTestsViewController

- (IBAction)login:(id)sender {
    [EcomapFetcher loginWithEmail:@"clic@ukr.net"
                      andPassword:@"eco"
                     OnCompletion:^(EcomapLoggedUser *user, NSError *error) {
                         if (!error) {
                             NSLog(@"User role: %@", user.role);
                             
                             //Read current logged user
                             EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
                             NSLog(@"User ID: %d", loggedUser.userID);
                             
                         } else {
                             NSLog(@"Error to login: %@", error);
                         }
                     }];
}

- (IBAction)currentUser:(id)sender {
    EcomapLoggedUser *loggedUser = [EcomapLoggedUser currentLoggedUser];
    NSLog(@"Email: %@", loggedUser.email);
}

- (IBAction)logout:(id)sender {
    [EcomapFetcher logoutUser:[EcomapLoggedUser currentLoggedUser] OnCompletion:^(BOOL result, NSError *error) {
        
    }];
}
- (IBAction)loadAllProblems:(id)sender {
    [EcomapFetcher loadAllProblemsOnCompletion:^(NSArray *problems, NSError *error) {
        if (!error) {
            NSLog(@"Loaded success! %d problems", [problems count] + 1);
        } else {
            NSLog(@"Error loading problems: %@", error);
        }
        
    }];
}
- (IBAction)loadProblemWithId:(id)sender {
    [EcomapFetcher loadProblemDetailsWithID:1
                               OnCompletion:^(EcomapProblemDetails *problemDetails, NSError *error) {
                                   if (!error) {
                                       NSLog(@"Loaded success! Details for 1 problem");
                                       NSLog(@"Titile %@", problemDetails.title);
                                   } else {
                                       NSLog(@"Error loading problem details: %@", error);
                                   }
                               }];
}
@end
