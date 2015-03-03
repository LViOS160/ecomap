//
//  ECMAdminFetcher.h
//  ecomap
//
//  Created by ohuratc on 02.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapFetcher.h"
#import "EcomapEditableProblem.h"

@interface EcomapAdminFetcher : EcomapFetcher

#pragma mark - GET Requests

// Put here your methods with GET requests

#pragma mark - POST Requests

// Put here your methods with POST requests

#pragma mark - PUT Requests

+ (void)changeProblem:(NSUInteger)problemID withNewProblem:(EcomapEditableProblem *)problemData onCompletion:(void(^)(NSData *result, NSError *error))completionHandler;

#pragma mark - DELETE request
+ (void)deleteComment:(NSUInteger)commentID onCompletion:(void(^)(NSError *error))completionHandler;

@end
