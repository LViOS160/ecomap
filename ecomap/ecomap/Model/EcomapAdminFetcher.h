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

#pragma mark - PUT requests

+ (void)changeProblem:(NSUInteger)problemID withNewProblem:(EcomapEditableProblem *)problemData onCompletion:(void(^)(NSData *result, NSError *error))completionHandler;

@end
