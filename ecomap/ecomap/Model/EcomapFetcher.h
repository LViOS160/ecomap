//
//  EcomapFetcher.h
//  EcomapFetcher
//
//  Created by Vasilii Kotsiuba on 2/3/15.
//  Copyright (c) 2015 Vasyl Kotsiuba. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EcomapProblemDetails;

@interface EcomapFetcher : NSObject
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~GET API for Problems~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//Load all problems to array in completionHandler not blocking the main thread
//NSArray *problems is a collection of EcomapProblem objects;
+ (void)loadAllProblemsOnCompletion:(void (^)(NSArray *problems, NSError *error))completionHandler;

//Load problem details not blocking the main thread
+ (void)loadProblemDetailsWithID:(NSUInteger)problemID OnCompletion:(void (^)(EcomapProblemDetails *problemDetails, NSError *error))completionHandler;
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~END GET API for Problems~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@end
