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


@implementation EcomapFetcher

#pragma mark - Load all Problems
+(void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler
{
    [self loadDataTaskWithURL:[EcomapURLFetcher URLforAllProblems]
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
    [self loadDataTaskWithURL:[EcomapURLFetcher URLforProblemWithID:problemID]
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

#pragma mark - Load data task
+(void)loadDataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData *JSON, NSError *error))completionHandler
{
    //Create new session to download JSON file
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    //Perform download task on different thread
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
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

@end
