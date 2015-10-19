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
#import "AFNetworking.h"
#import "EcomapProblemDetails.h"

//Setup DDLog
#import "GlobalLoggerLevel.h"

@implementation EcomapAdminFetcher

+ (void)changeProblem:(EcomapProblemDetails *)problem withNewProblem:(EcomapEditableProblem *)editableProblem onCompletion:(void(^)(NSData *, NSError *))completionHandler
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSDictionary *dictionary = @{
                                 ECOMAP_PROBLEM_STATUS : editableProblem.isSolved ? @"SOLVED" : @"UNSOLVED",
                                 ECOMAP_PROBLEM_TYPE_ID : @(problem.problemTypesID),
                                 ECOMAP_PROBLEM_SEVERITY : [NSString stringWithFormat:@"%lu", editableProblem.severity],
                                 ECOMAP_PROBLEM_TITLE : editableProblem.title,
                                 ECOMAP_PROBLEM_LONGITUDE : @(problem.longitude),
                                 ECOMAP_PROBLEM_CONTENT : editableProblem.content,
                                 ECOMAP_PROBLEM_LATITUDE : @(problem.latitude),
                                 ECOMAP_PROBLEM_PROPOSAL : editableProblem.proposal
                                 };
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString *baseUrl = [ECOMAP_ADDRESS stringByAppendingString:ECOMAP_API];
    NSString *urlForRequest = [baseUrl stringByAppendingString:[EcomapURLFetcher URLforProblemWithID:problem.problemID]];
    
    [manager PUT:urlForRequest parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"OK request for updating problem");
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        
        DDLogVerbose(@"ERROR: %@", error);
        completionHandler((NSData *)dictionary,error);
    }];
}

+ (void)changeComment:(NSUInteger)commentID withNewContent:(NSString *)content onCompletion:(void(^)(NSData *, NSError *))completionHandler
{
    
    NSDictionary *dictionary = @{  @"content" : content  };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSString *baseUrl = [ECOMAP_ADDRESS stringByAppendingString:ECOMAP_API];
    NSString *urlForRequest = [baseUrl stringByAppendingString:[EcomapURLFetcher URLforCommentWithID:commentID]];
    
    [manager PUT:urlForRequest parameters:dictionary success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"OK request for updating comment");
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        DDLogVerbose(@"ERROR: %@", error);
        completionHandler((NSData *)dictionary,error);
    }];
    
}

+ (void)deleteComment:(NSUInteger)commentID onCompletion:(void (^)(NSError *))completionHandler
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
    [manager setRequestSerializer:jsonRequestSerializer];
    
    NSString *baseUrl = [ECOMAP_ADDRESS stringByAppendingString:ECOMAP_API];
    NSString *urlForRequest = [baseUrl stringByAppendingString:[EcomapURLFetcher URLforCommentWithID:commentID]];
    
    [manager DELETE:urlForRequest parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"OK request for deleting comment");
    }
            failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        DDLogVerbose(@"ERROR: %@", error);
        completionHandler(error);
    }];
}

+ (void)deleteProblem:(NSUInteger)problemID onCompletion:(void(^)(NSError *error))completionHandler
{
  
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFJSONRequestSerializer *jsonRequestSerializer = [AFJSONRequestSerializer serializer];
    [manager setRequestSerializer:jsonRequestSerializer];
    
    NSString *baseUrl = [ECOMAP_ADDRESS stringByAppendingString:ECOMAP_API];
    NSString *urlForRequest = [baseUrl stringByAppendingString:[EcomapURLFetcher URLforProblemWithID:problemID]];
    
    [manager DELETE:urlForRequest parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"OK request for deleting problem");
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
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
