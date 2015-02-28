//
//  EcomapUserFetcher.m
//  ecomap
//
//  Created by Vasya on 3/1/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapUserFetcher.h"
#import "DataTasks.h"
#import "JSONparser.h"
#import "NetworkActivityIndicator.h"
#import <FacebookSDK/FacebookSDK.h>

//Value-Object classes
#import "EcomapLoggedUser.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation EcomapUserFetcher
#pragma mark - Login
+ (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(EcomapLoggedUser *loggedUser, NSError *error))completionHandler
{
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforLogin]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"email" : email, @"password" : password};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData
                                                   options:0
                                                     error:nil];
    [DataTasks uploadDataTaskWithRequest:request
                                fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           EcomapLoggedUser *loggedUser = nil;
                           NSDictionary *userInfo = nil;
                           if (!error) {
                               //Parse JSON
                               userInfo = [JSONparser parseJSONtoDictionary:JSON];
                               //Create EcomapLoggedUser object
                               loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
                               
                               if (loggedUser) {
                                   DDLogVerbose(@"LogIN to ecomap success! %@", loggedUser.description);
                                   
                                   //Create cookie
                                   NSHTTPCookie *cookie = [self createCookieForUser:[EcomapLoggedUser currentLoggedUser]];
                                   if (cookie) {
                                       DDLogVerbose(@"Cookies created success!");
                                       //Put cookie to NSHTTPCookieStorage
                                       [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
                                       [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:@[cookie]
                                                                                          forURL:[EcomapURLFetcher URLforServer]
                                                                                 mainDocumentURL:nil];
                                   }
                               }
                           } else {
                               DDLogError(@"Error to login to ecomap server: %@", [error localizedDescription]);
                           }
                           
                           //set up completionHandler
                           completionHandler(loggedUser, error);
                       }];
}

#define FACEBOOK_PERMISSIONS @[@"public_profile", @"email"]
#define FACEBOOK_INFO_PARAMETERS @{@"fields": @"first_name, last_name, email"}
+ (void)loginWithFacebookOnCompletion:(void (^)(EcomapLoggedUser *loggedUserFB, NSError *error))completionHandler
{
    [[NetworkActivityIndicator sharedManager] startActivity];
    __block EcomapLoggedUser *loggedUserFB = nil;
    __block NSError *errorFB = nil;
    //check current FB session state
    if ([FBSession activeSession].state != FBSessionStateOpen &&
        [FBSession activeSession].state != FBSessionStateOpenTokenExtended) {
        
        [FBSession openActiveSessionWithReadPermissions:FACEBOOK_PERMISSIONS
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          
                                          [[NetworkActivityIndicator sharedManager] endActivity];
                                          // Handle the session state.
                                          // Usually, the only interesting states are the opened session, the closed session and the failed login.
                                          if (!error) {
                                              // In case that there's not any error, then check if the session opened or closed.
                                              if (status == FBSessionStateOpen) {
                                                  DDLogVerbose(@"Facebook session open success!");
                                                  
                                                  // The session is open. Get the user information.
                                                  [FBRequestConnection startWithGraphPath:@"me"
                                                                               parameters:FACEBOOK_INFO_PARAMETERS
                                                                               HTTPMethod:@"GET"
                                                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                            if (!error) {
                                                                                NSString *name = [result objectForKey:@"first_name"];
                                                                                NSString *surname = [result objectForKey:@"last_name"];
                                                                                NSString *email = [result objectForKey:@"email"];
                                                                                NSString *password = [result objectForKey:@"id"];
                                                                                DDLogVerbose(@"User (%@ %@) info received from facebook!", name, surname);
                                                                                
                                                                                //Try to login. If not success, then try to register and login
                                                                                [self loginWithEmail:email
                                                                                         andPassword:password
                                                                                        OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                                                                            if (!error && loggedUser) {
                                                                                                completionHandler (loggedUser, nil);
                                                                                                return;
                                                                                            } else {
                                                                                                
                                                                                                //Try to register
                                                                                                [self registerWithName:name
                                                                                                            andSurname:surname
                                                                                                              andEmail:email
                                                                                                           andPassword:password
                                                                                                          OnCompletion:^(NSError *error) {
                                                                                                              if (!error) {
                                                                                                                  
                                                                                                                  //Try to login
                                                                                                                  [self loginWithEmail:email
                                                                                                                           andPassword:password
                                                                                                                          OnCompletion:^(EcomapLoggedUser *loggedUser, NSError *error) {
                                                                                                                              if (!error && loggedUser) {
                                                                                                                                  completionHandler (loggedUser, nil);
                                                                                                                                  return;
                                                                                                                              } else {
                                                                                                                                  // In case an error to login has occured
                                                                                                                                  errorFB = error;
                                                                                                                                  [self closeFacebookSession];
                                                                                                                              }
                                                                                                                          }];
                                                                                                              } else {
                                                                                                                  // In case an error to register has occured.
                                                                                                                  errorFB = error;
                                                                                                                  [self closeFacebookSession];
                                                                                                              }
                                                                                                              
                                                                                                              //Return complition handler
                                                                                                              completionHandler (loggedUserFB, errorFB);
                                                                                                          }];
                                                                                            }
                                                                                            
                                                                                            
                                                                                        }];
                                                                                
                                                                                
                                                                            } else {
                                                                                //In case an error to get user info from facebook has occured
                                                                                DDLogError(@"Error getting user info from facebook: %@", [error localizedDescription]);
                                                                                errorFB = error;
                                                                                [self closeFacebookSession];
                                                                            }
                                                                        }];
                                                  
                                                  
                                              }
                                              else if (status == FBSessionStateClosed || status == FBSessionStateClosedLoginFailed){
                                                  // A session was closed or the login was failed or canceled. Update the UI accordingly.
                                                  DDLogError(@"Error login with facebook: a session was closed or the login was failed or canceled");
                                              }
                                          }
                                          else{
                                              // In case an error to connect to facebook has occured, then just log the error.
                                              DDLogError(@"Error login with facebook: %@", [error localizedDescription]);
                                              errorFB = error;
                                          }
                                          
                                          //Return complition handler
                                          //completionHandler(loggedUserFB, errorFB);
                                      }];
    } else {
        [self closeFacebookSession];
        [[NetworkActivityIndicator sharedManager] endActivity];
        
        //Return complition handler
        completionHandler(loggedUserFB, errorFB);
    }
    
}

+ (void)closeFacebookSession
{
    [[FBSession activeSession] close];
    DDLogVerbose(@"Facebook session closed");
}

#pragma mark - Logout
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL result, NSError *error))completionHandler
{
    //Set up session configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [DataTasks dataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforLogout]]
              sessionConfiguration:sessionConfiguration
                 completionHandler:^(NSData *JSON, NSError *error) {
                     BOOL result = NO;
                     if (!error) {
                         //Read response Data (it is not JSON actualy, just plain text)
                         NSString *statusResponse =[[NSString alloc]initWithData:JSON encoding:NSUTF8StringEncoding];
                         result = [statusResponse isEqualToString:@"OK"] ? YES : NO;
                         DDLogVerbose(@"Logout %@!", statusResponse);
                         
                         //Clear coockies
                         NSArray * cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[EcomapURLFetcher URLforServer]];
                         for (NSHTTPCookie *cookie in cookies) {
                             [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                         }
                         
                         //Set userDefaults @"isUserLogged" key to NO to delete EcomapLoggedUser object
                         if (loggedUser) {
                             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                             [defaults setObject:@"NO" forKey:@"isUserLogged"];
                         }
                     } else {
                         DDLogError(@"Error to logout from ecomap server: %@", [error localizedDescription]);
                     }
                     completionHandler(result, error);
                 }];
    
    //Close facebook session if there is one
    if ([FBSession activeSession].state == FBSessionStateOpen ||
        [FBSession activeSession].state == FBSessionStateOpenTokenExtended) {
        [[FBSession activeSession] close];
        DDLogVerbose(@"Facebook session closed");
    }
}

#pragma mark - Register
+ (void)registerWithName:(NSString*)name andSurname:(NSString*) surname andEmail: (NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(NSError *error))completionHandler{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforRegister]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"first_name": name, @"last_name":surname, @"email" : email, @"password" : password};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData
                                                   options:0
                                                     error:nil];
    [DataTasks uploadDataTaskWithRequest:request
                                fromData:data
                    sessionConfiguration:sessionConfiguration
                       completionHandler:^(NSData *JSON, NSError *error) {
                           if (!error) {
                               DDLogVerbose(@"Register to ecomap success!");
                           } else {
                               DDLogError(@"Error to register on ecomap server: %@", [error localizedDescription]);
                           }
                           
                           //set up completionHandler
                           completionHandler(error);
                       }];
    
    
}

#pragma mark - Cookies
+ (NSHTTPCookie *)createCookieForUser:(EcomapLoggedUser *)userData
{
    NSHTTPCookie *cookie = nil;
    if (userData) {
        //Form userName value
        NSString *userName = userData.name ? userData.name : @"null";
        NSString *userNameValue = [NSString stringWithFormat:@"userName=%@", userName];
        
        //Form userSurname value
        NSString *userSurname = userData.surname ? userData.surname : @"null";
        NSString *userSurnameValue = [NSString stringWithFormat:@"userSurname=%@", userSurname];
        
        //Form userRole value
        NSString *userRole = userData.role ? userData.role : @"null";
        NSString *userRoleValue = [NSString stringWithFormat:@"userRole=%@", userRole];
        
        //Form token value
        NSString *token = userData.token ? userData.token : @"null";
        NSString *tokenValue = [NSString stringWithFormat:@"token=%@", token];
        
        //Form id value
        NSString *idValue = [NSString stringWithFormat:@"id=%lu", (unsigned long)userData.userID];
        
        //Form userEmail value
        NSString *userEmail = userData.email ? [userData.email stringByReplacingOccurrencesOfString:@"@" withString:@"%"] : @"null";
        NSString *userEmailValue = [NSString stringWithFormat:@"userEmail=%@", userEmail];
        
        //Form cookie value
        NSString *cookieValue = [NSString stringWithFormat:@"%@; %@; %@; %@; %@; %@", userNameValue, userSurnameValue, userRoleValue, tokenValue, idValue, userEmailValue];
        
        //Form cookie properties
        NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [EcomapURLFetcher serverDomain], NSHTTPCookieDomain,
                                    @"/", NSHTTPCookiePath,
                                    @"ECOMAPCOOKIE", NSHTTPCookieName,
                                    cookieValue, NSHTTPCookieValue,
                                    [[NSDate date] dateByAddingTimeInterval:864000], NSHTTPCookieExpires, //10 days
                                    nil];
        
        //Form cookie
        cookie = [NSHTTPCookie cookieWithProperties:properties];
    }
    
    return cookie;
}

@end
