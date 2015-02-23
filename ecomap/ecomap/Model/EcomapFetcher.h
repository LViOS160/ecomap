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

@class EcomapProblemDetails;
@class EcomapLoggedUser;
@class EcomapProblem;
@class EcomapCommentsChild;

@interface EcomapFetcher : NSObject

#pragma mark - GET API
//Load all problems to array in completionHandler not blocking the main thread
//NSArray *problems is a collection of EcomapProblem objects;
+ (void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler;

//Load problem details not blocking the main thread
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler;


//Load tittles of resources not blocking the main thread
+(void)loadResourcesOnCompletion:(void (^)(NSArray *resources, NSError *error))completionHandler;
// Load all alias content
+ (void)registerToken:(NSString *)token
         OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler;

// Load alias of resources (its a path to details of resources)
+(void)loadAliasOnCompletion:(void (^)(NSArray *alias, NSError *error))completionHandler String:(NSString*)str;

// Load stats for particular time period to draw a pie chart in Stats View Controller
+ (void)loadStatsForPeriod:(EcomapStatsTimePeriod)period onCompletion:(void (^)(NSArray *stats, NSError *error))completionHandler;

// Load general statistics to draw top label in Stats View Controller
+ (void)loadGeneralStatsOnCompletion:(void (^)(NSArray *stats, NSError *error))completionHandler;

// Load top charts of problems to show them in Top Chart List View Controller
+ (void)loadTopChartsOnCompletion:(void (^)(NSArray *charts, NSError *error))completionHandler;

//Logout
+ (void)logoutUser:(EcomapLoggedUser *)loggedUser OnCompletion:(void (^)(BOOL result, NSError *error))completionHandler;

//Load small image (for thumnails)
+ (void)loadSmallImagesFromLink:(NSString *)link OnCompletion:(void (^)(UIImage *image, NSError *error))completionHandler;

#pragma mark - POST API
//Login
//Use [EcomapLoggedUser currentLoggedUser] to get an instance of current logged user anytime
+ (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(EcomapLoggedUser *loggedUser, NSError *error))completionHandler;

+ (void)problemPost:(EcomapProblem*)problem
     problemDetails:(EcomapProblemDetails*)problemDetails
               user:(EcomapLoggedUser*)user
       OnCompletion:(void (^)(NSString *result, NSError *error))completionHandler;

//Registration. We don't need the instance of logged user after registration
// added by Gregory Chereda
+ (void)registerWithName:(NSString*)name andSurname:(NSString*) surname andEmail: (NSString *)email andPassword:(NSString *)password OnCompletion:(void (^)(NSError *error))completionHandler;

//POST method for votes
+ (void)addVoteForProblem:(EcomapProblemDetails *)problemDetails withUser:(EcomapLoggedUser *)user OnCompletion:(void (^)(NSError *error))completionHandler;

+(void)createComment:(NSString*)userId andName:(NSString*)name
          andSurname:(NSString*)surname andContent:(NSString*)content andProblemId:(NSString*)probId
        OnCompletion:(void (^)(EcomapCommentsChild *obj,NSError *error))completionHandler;

@end
