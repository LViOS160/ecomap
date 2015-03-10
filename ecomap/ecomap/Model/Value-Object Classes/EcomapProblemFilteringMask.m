//
//  EcomapProblemFilteringMask.m
//  ecomap
//
//  Created by ohuratc on 19.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapProblemFilteringMask.h"
#import "EcomapPathDefine.h"

@implementation EcomapProblemFilteringMask

- (instancetype)init
{
    self = [super init];
    
    self.fromDate = [NSDate dateWithTimeIntervalSince1970:0];
    self.toDate = [NSDate date];
    self.problemTypes = [[EcomapProblemFilteringMask validProblemTypeIDs] mutableCopy];
    self.showSolved = YES;
    self.showUnsolved = YES;

    return self;
}

+ (NSArray *)validProblemTypeIDs
{
    return @[@1, @2, @3, @4, @5, @6, @7];
}

// Very simple method :)
- (void)markProblemType:(NSInteger)problemTypeID
{
    if([self.problemTypes containsObject:@(problemTypeID)]) {
        [self.problemTypes removeObject:@(problemTypeID)];
    } else {
        [self.problemTypes addObject:@(problemTypeID)];
    }
}

@end
