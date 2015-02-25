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
    
    _fromDate = [NSDate dateWithTimeIntervalSince1970:0];
    _toDate = [NSDate date];
    _problemTypes = [EcomapProblemFilteringMask validProblemTypeIDs];
    _showSolved = YES;
    _showUnsolved = YES;

    return self;
}

+ (NSArray *)validProblemTypeIDs
{
    return @[@1, @2, @3, @4, @5, @6, @7];
}

@end
