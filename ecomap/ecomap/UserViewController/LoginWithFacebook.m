//
//  LoginWithFacebook.m
//  ecomap
//
//  Created by Vasya on 3/7/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "LoginWithFacebook.h"
#import "EcomapUserFetcher.h"
#import "InfoActions.h"

@interface LoginWithFacebook ()

@end

@implementation LoginWithFacebook

+ (void)loginWithFacebook:(void(^)(BOOL result))complitionHandler
{
    [InfoActions startActivityIndicatorWithUserInteractionEnabled:NO];
    [EcomapUserFetcher loginWithFacebookOnCompletion:^(EcomapLoggedUser *loggedUserFB, NSError *error) {
        [InfoActions stopActivityIndicator];
        BOOL loginResult = NO;
        
        //Handle response
        [self handleResponseToLoginFromFacebookWithError:error
                                                       andLoggedUser:loggedUserFB];
        if (!error && loggedUserFB) {
            
            loginResult = YES;
            //show popup greeting for logged user
            [InfoActions showPopupWithMesssage:[NSString stringWithFormat:NSLocalizedString(@"Вітаємо, %@!", @"Welcome, {User Name}"), loggedUserFB.name]];
        }
        
        //Call complitionHandler
        complitionHandler(loginResult);
        
    }];  //end of EcomapUserFetchen complition block

}

+ (void)handleResponseToLoginFromFacebookWithError:(NSError *)error andLoggedUser:(EcomapLoggedUser *)user
{
    NSString *faceboolLoginErrorTitle = NSLocalizedString(@"Помилка входу через Facebook", @"Alert title of error for facebook");
    
    if (!error && !user) {
        [InfoActions showAlertWithTitile:faceboolLoginErrorTitle
                              andMessage:NSLocalizedString(@"Неможливо отримати дані для авторизації на Ecomap", @"Alert message_1 of error for facebook")];
    } else if (error.code == 400 ) {
        [InfoActions showAlertWithTitile:faceboolLoginErrorTitle
                              andMessage:NSLocalizedString(@"Користувач з такою email-адресою вже зареєстрований", @"Alert message_2 of error for facebook")];
    } else if (error) {
        [InfoActions showAlertWithTitile:faceboolLoginErrorTitle
                              andMessage:[error localizedDescription]];
    }
}

@end
