//
//  EcomapProblemFilteringMask.m
//  ecomap
//
//  Created by ohuratc on 19.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapProblemFilteringMask.h"
#import "EcomapPathDefine.h"
#import "InfoActions.h"

@implementation EcomapProblemFilteringMask

#pragma mark - Properties

- (instancetype)init
{
    self = [super init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.fromDate = [dateFormatter dateFromString:@"2014-02-18"];
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

// Check wether Problem type array consists type ID.
// If not add it, in other case remove it from array.
- (void)markProblemType:(NSInteger)problemTypeID
{
    if([self.problemTypes containsObject:@(problemTypeID)]) {
        [self.problemTypes removeObject:@(problemTypeID)];
    } else {
        [self.problemTypes addObject:@(problemTypeID)];
    }
}

// Overridden description
- (NSString *)description
{
    NSLog(@"Start date: %@", self.fromDate);
    NSLog(@"End date: %@", self.toDate);
    NSLog(@"Problem types: %@", self.problemTypes);
    NSLog(@"Show solved: %@", self.showSolved ? @"YES" : @"NO");
    NSLog(@"Show unsolved: %@", self.showUnsolved ? @"YES" : @"NO");
    return @"";
}

@end
