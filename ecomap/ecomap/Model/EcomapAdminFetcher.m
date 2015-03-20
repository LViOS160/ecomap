//
//  ECMAdminFetcher.m
//  ecomap
//
//  Created by ohuratc on 02.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapAdminFetcher.h"
#import "EcomapLoggedUser.h"
#import "EcomapURLFetcher.h"
#import "DataTasks.h"
#import "JSONParser.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation EcomapAdminFetcher

+ (void)changeProblem:(NSUInteger)problemID withNewProblem:(EcomapEditableProblem *)problemData onCompletion:(void(^)(NSData *, NSError *))completionHandler;
{
    // Get current user
    EcomapLoggedUser *user = [EcomapLoggedUser currentLoggedUser];
    
    // Create JSON data to PUT on the server
    NSDictionary *dictionary = @{ @"Content" : problemData.content,
                                  @"ProblemStatus" : [self BOOLtoInteger:problemData.isSolved],
                                  @"Proposal" : problemData.proposal,
                                  @"Severity" : [NSNumber numberWithInteger:problemData.severity],
                                  @"Title" : problemData.title
                                };
    
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    // Send data only if user is administrator and logged in
    if(user && [user.role isEqualToString:@"administrator"]) {
        // Set up configuration
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configuration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
        
        // Set up request
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforEditingProblem:problemID]];
        [request setHTTPMethod:@"PUT"];
        
        [DataTasks uploadDataTaskWithRequest:request
                                    fromData:JSONData
                        sessionConfiguration:configuration
                           completionHandler:^(NSData *JSON, NSError *error) {
                               if(error) {
                                   DDLogVerbose(@"ERROR: %@", error);
                               }
                               
                               // Set up completion handler
                               completionHandler(JSON, error);
                           }];
        
    } else {
        DDLogVerbose(@"Error! You should be logged in and have administrator permissions!");
    }
}


+ (void)deleteComment:(NSUInteger)commentID onCompletion:(void (^)(NSError *))completionHandler
{
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforDeletingComment:commentID]];
    NSLog(@"__%@__",request);
    [request setHTTPMethod:@"DELETE"];
    
    [DataTasks dataTaskWithRequest:request sessionConfiguration:sessionConfiguration completionHandler:^(NSData *JSON, NSError *error) {
        if(error)
           DDLogVerbose(@"ERROR: %@", error);
        completionHandler(error);
    }];
}

+ (void)deleteProblem:(NSUInteger)problemID onCompletion:(void(^)(NSError *error))completionHandler
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforDeleteProblemWithID:problemID]];
    NSLog(@"__%@__",request);
    [request setHTTPMethod:@"DELETE"];
    
    [DataTasks dataTaskWithRequest:request sessionConfiguration:sessionConfiguration completionHandler:^(NSData *JSON, NSError *error) {
        if(error)
            DDLogVerbose(@"ERROR: %@", error);
        completionHandler(error);
    }];
}
+(void)deletePhotoWithLink:(NSString*)link onCompletion:(void(^)(NSError *error))completionHandler
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Content-Type" : @"application/json;charset=UTF-8"}];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[EcomapURLFetcher URLforDeletingPhoto:link]];
    [request setHTTPMethod:@"DELETE"];
    [DataTasks dataTaskWithRequest:request sessionConfiguration:sessionConfiguration completionHandler:^(NSData *JSON, NSError *error) {
        if(error)
            DDLogVerbose(@"ERROR: %@", error);
        completionHandler(error);
    }];

    
}

// Utility method. Convert BOOL to NSNumber.
+ (NSNumber *)BOOLtoInteger:(BOOL)flag
{
    return flag ? @1 : @0;
}

@end
