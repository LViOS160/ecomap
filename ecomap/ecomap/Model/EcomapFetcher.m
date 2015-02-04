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
                        //Parse JSON
                        problemsFromJSON = (NSArray *)[NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        problems = [NSMutableArray array];
                        //Fill array with EcomapProblem
                        for (NSDictionary *problem in problemsFromJSON) {
                            EcomapProblem *ecoProblem = [[EcomapProblem alloc] initWithProblem:problem];
                            [problems addObject:ecoProblem];
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
                        //Check if we have a problem with such problemID
                        //Parse JSON
                        id answer = [NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                        if ([answer isKindOfClass:[NSDictionary class]]) {
                            //Return error
                            NSError *err = [[NSError alloc] initWithDomain:NSMachErrorDomain code:404 userInfo:answer];
                            completionHandler(problemDetails, err);
                            return;
                        }
                        
                        //Extract problemDetails from JSON
                        problem = (NSDictionary *)[[[NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error] objectAtIndex:ECOMAP_PROBLEM_DETAILS_DESCRIPTION] firstObject];
                        problemDetails = [[EcomapProblemDetails alloc] initWithProblem:problem];
                    }
                    //Return problemDetails
                    completionHandler(problemDetails, error);
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
                          userInfo = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:JSON options:0 error:&error];
                      }
                      loggedUser = [[EcomapLoggedUser alloc] initWithUserInfo:userInfo];
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
                                                    JSON = data;
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
    //Perform download task on different thread
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSData *JSON = nil;
        if (!error) {
            //Cast an instance of NSHTTURLResponse from the response and use its statusCode method
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            //NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
            if (httpResponse.statusCode == 200) {
                JSON = data;
            } else {
                NSError *unauthorizedError = [[NSError alloc] initWithDomain:@"Unauthorized user" code:400 userInfo:@{@"error" : @"Incorect email or password"}];
                error = unauthorizedError;
            }
            
        }
        //Perform completionHandler task on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(JSON, error);
        });
    }];
    [task resume];
}

@end
