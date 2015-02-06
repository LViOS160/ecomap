//
//  EcomapFetcher.m
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import "EcomapFetcher.h"
#import "EcomapPathDefine.h"
#import "EcomapURLFetcher.h"
#import "EcomapProblem.h"
#import "EcomapProblemDetails.h"
#import "EcomapLoggedUser.h"


@implementation EcomapFetcher

#pragma mark - Load all Problems
+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [self loadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforAllProblems]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSMutableArray *problems = nil;
                    NSArray *problemsFromJSON = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Parse JSON
                            problemsFromJSON = [EcomapFetcher parseJSONtoArray:JSON];
                            
                            //Fill problems array
                            if (problemsFromJSON) {
                                problems = [NSMutableArray array];
                                //Fill array with EcomapProblem
                                for (NSDictionary *problem in problemsFromJSON) {
                                    EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
                                    [problems addObject:ecoProblem];
                                }
                            }
                            
                        }
                    }
                    //set up completionHandler
                    completionHandler(problems, error);
                }];
    
}

#pragma mark - Load Problem with ID
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler
{
    [self loadDataTaskWithRequest:[NSURLRequest requestWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]]
             sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]
                completionHandler:^(NSData *JSON, NSError *error) {
                    NSDictionary *problem = nil;
                    EcomapProblemDetails *problemDetails = nil;
                    if (!error) {
                        //Extract received data
                        if (JSON != nil) {
                            //Check if we have a problem with such problemID.
                            //If there is no one, server give us back Dictionary with "error" key
                            //Parse JSON
                            NSDictionary *answerFromServer = [EcomapFetcher parseJSONtoDictionary:JSON];
                            if (answerFromServer) {
                                //Return error. Form error to be passed to completionHandler
                                NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                                            code:404
                                                                        userInfo:answerFromServer];
                                completionHandler(problemDetails, error);
                                return;
                            }
                            
                            
                            //Extract problemDetails from JSON
                            //Parse JSON
                            problem = [[[EcomapFetcher parseJSONtoArray:JSON] objectAtIndex:ECOMAP_PROBLEM_DETAILS_DESCRIPTION] firstObject];
                            problemDetails = [[EcomapProblemDetails alloc] initWithProblem:problem];
                        }
                    }
                    
                    //Return problemDetails
                    completionHandler(problemDetails, error);
                }];
}

#pragma mark - Register

// added by Gregory Chereda
+ (void)registerWithName:(NSString*)name andSurname:(NSString*) surname andEmail: (NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(NSError *error))completionHandler{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    
    //Set up request
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforRegister]];
    [request setHTTPMethod:@"POST"];
    
    //Create JSON data to send to  server
    NSDictionary *loginData = @{@"first_name": name, @"last_name":surname, @"email" : email, @"password" : password};
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [self uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                     // EcomapLoggedUser *loggedUser = nil;
                      //NSDictionary *userInfo = nil;
                      if (!error) {
                          //Parse JSON
                          //userInfo = [EcomapFetcher parseJSONtoDictionary:JSON];
//                          loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
//                          //Log success login
//                          if (loggedUser) {
                              //NSLog(@"LogIN to ecomap success! %@", loggedUser.description);
//                          }
                      }
                      
                      //set up completionHandler
                      completionHandler(error);
                  }];

    
}



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
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:0
                                                     error:nil];
    [self uploadDataTaskWithRequest:request
                           fromData:data
               sessionConfiguration:sessionConfiguration
                  completionHandler:^(NSData *JSON, NSError *error) {
                      EcomapLoggedUser *loggedUser = nil;
                      NSDictionary *userInfo = nil;
                      if (!error) {
                          //Parse JSON
                          userInfo = [EcomapFetcher parseJSONtoDictionary:JSON];
                          loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
                          //Log success login
                          if (loggedUser) {
                              NSLog(@"LogIN to ecomap success! %@", loggedUser.description);
                          }
                      }
                      
                      //set up completionHandler
                      completionHandler(loggedUser, error);
                  }];
}

#pragma mark - Load data task
+(void)loadDataTaskWithRequest:(NSURLRequest *)request sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform download task on different thread
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                NSData *JSON = nil;
                                                if (!error) {
                                                    //Set data
                                                    if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                                                        //Log to console
                                                        NSLog(@"JSON data downloaded success from URL: %@", request.URL);
                                                        JSON = data;
                                                    } else {
                                                        //Create error message
                                                        error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
                                                    }
                                                }
                                                //Perform completionHandler task on main thread
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    completionHandler(JSON, error);
                                                });
                                            }];
    
    [task resume];
}

#pragma mark - upLoad data task
+(void)uploadDataTaskWithRequest:(NSURLRequest *)request fromData:(NSData *)data sessionConfiguration:(NSURLSessionConfiguration *)configuration completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    //Perform upload task on different thread
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *JSON = nil;
        if (!error) {
            //Set data
            if ([EcomapFetcher statusCodeFromResponse:response] == 200) {
                //Log to console
                NSLog(@"Data uploaded success to url: %@", request.URL);
                JSON = data;
            } else {
                //Create error message
                error = [EcomapFetcher errorForStatusCode:[EcomapFetcher statusCodeFromResponse:response]];
            }
        }
        //Perform completionHandler task on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(JSON, error);
        });
    }];
    [task resume];
}

#pragma mark - Parse JSON data to Array
+ (NSArray *)parseJSONtoArray:(NSData *)JSON
{
    NSArray *dataFromJSON = nil;
    NSError *error = nil;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error) {
        if ([parsedJSON isKindOfClass:[NSArray class]]) {
            dataFromJSON = (NSArray *)parsedJSON;
        }
    } else {
        NSLog(@"Error parsing JSON data: %@", error);
    }
    
    return dataFromJSON;
}

#pragma mark - Parse JSON data to Dictionary
+ (NSDictionary *)parseJSONtoDictionary:(NSData *)JSON
{
    NSDictionary *dataFromJSON = nil;
    NSError *error = nil;
    id parsedJSON = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
    if (!error) {
        if ([parsedJSON isKindOfClass:[NSDictionary class]]) {
            dataFromJSON = (NSDictionary *)parsedJSON;
        }
    } else {
        NSLog(@"Error parsing JSON data: %@", error);
    }
    
    return dataFromJSON;
}

#pragma mark - Get status code
+(NSInteger)statusCodeFromResponse:(NSURLResponse *)response
{
    //Cast an instance of NSHTTURLResponse from the response and use its statusCode method
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    return httpResponse.statusCode;
}

#pragma mark - Form error for status code
//Form error for different status code. (Fill more case: if needed)
+(NSError *)errorForStatusCode:(NSInteger)statusCode
{
    
    NSError *error = nil;
    switch (statusCode) {
        case 400:
            error = [[NSError alloc] initWithDomain:@"Bad Request" code:statusCode userInfo:@{@"error" : @"Incorect email or password"}];
            break;
        
        case 404:
            error = [[NSError alloc] initWithDomain:@"Not Found" code:statusCode userInfo:@{@"error" : @"The server has not found anything matching the Request URL"}];
            break;
            
        case 401: // added by Gregory Chereda
            error = [[NSError alloc] initWithDomain:@"Unauthorized" code:401 userInfo:@{@"error" : @"Request error"}];
        default:
            error = [[NSError alloc] initWithDomain:@"Unknown error" code:statusCode userInfo:@{@"error" : @"Unknown error"}];
            break;
    }
    return error;
}

@end
