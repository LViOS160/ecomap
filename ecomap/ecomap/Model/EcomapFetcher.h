//
//  EcomapFetcher.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EcomapProblemDetails;
@class EcomapLoggedUser;

@interface EcomapFetcher : NSObject

#pragma mark - GET API
//Load all problems to array in completionHandler not blocking the main thread
//NSArray *problems is a collection of EcomapProblem objects;
+ (void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler;

//Load problem details not blocking the main thread
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler;

//Logout
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL *result, NSError *error))completionHandler;

#pragma mark - POST API
//Login
//Use [EcomapLoggedUser currentLoggedUser] to get an instance of current logged user
+ (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(EcomapLoggedUser *loggedUser, NSError *error))completionHandler;

+ (void)problemPost:(void (^)())completionHandler;

//Registration. We don't need the instance of logged user after registration
// added by Gregory Chereda
+ (void)registerWithName:(NSString*)name andSurname:(NSString*) surname andEmail: (NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(NSError *error))completionHandler;

@end
