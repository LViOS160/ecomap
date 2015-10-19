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

+ (void)changeProblem:(EcomapProblemDetails *)problem withNewProblem:(EcomapEditableProblem *)editableProblem onCompletion:(void(^)(NSData *, NSError *))completionHandler;

+ (void)changeComment:(NSUInteger)commentID withNewContent:(NSString *)content onCompletion:(void(^)(NSData *, NSError *))completionHandler;

#pragma mark - DELETE requests
+ (void)deleteComment:(NSUInteger)commentID onCompletion:(void(^)(NSError *error))completionHandler;

+ (void)deleteProblem:(NSUInteger)problemID onCompletion:(void(^)(NSError *error))completionHandler;

+ (void)deletePhotoWithLink:(NSString*)link onCompletion:(void(^)(NSError *error))completionHandler;

@end
