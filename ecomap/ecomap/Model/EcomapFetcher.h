//
//  EcomapFetcher.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EcomapURLFetcher.h"

@class EcomapLoggedUser;
@class EcomapProblemDetails;
@class EcomapProblem;
@class EcomapCommentaries;

@interface EcomapFetcher : NSObject

#pragma mark - GET API
//Load all problems to array in completionHandler not blocking the main thread
//NSArray *problems is a collection of EcomapProblem objects;
+ (void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler;

//Load problem details not blocking the main thread
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler;

// Load alias of resources (its a path to details of resources)
+(void)loadAliasOnCompletion:(void (^)(NSArray *alias, NSError *error))completionHandler String:(NSString*)str;

//Load tittles of resources not blocking the main thread
+(void)loadResourcesOnCompletion:(void (^)(NSArray *resources, NSError *error))completionHandler;
// Load all alias content
+ (void)registerToken:(NSString *)token
         OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler;

#pragma mark - POST API
+ (void)problemPost:(EcomapProblem*)problem
     problemDetails:(EcomapProblemDetails*)problemDetails
               user:(EcomapLoggedUser*)user
       OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler;

//POST method for votes
+ (void)addVoteForProblem:(EcomapProblemDetails *)problemDetails withUser:(EcomapLoggedUser *)user OnCompletion:(void (^)(NSError *error))completionHandler;

+(void)createComment:(NSString*)userId andName:(NSString*)name
          andSurname:(NSString*)surname andContent:(NSString*)content andProblemId:(NSString*)probId
        OnCompletion:(void (^)(EcomapCommentaries *obj,NSError *error))completionHandler;

+ (void)addPhotos:(NSArray*)photos
        toProblem:(NSUInteger)problemId
             user:(EcomapLoggedUser*)user
     OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler;

@end
