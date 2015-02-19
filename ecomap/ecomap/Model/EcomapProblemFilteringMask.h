//
//  EcomapProblemFilteringMask.h
//  ecomap
//
//  Created by ohuratc on 19.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapProblemFilteringMask : NSObject

@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSArray *problemTypes; // of NSUInteger Problem's Type ID
@property (nonatomic) BOOL showSolved;
@property (nonatomic) BOOL showUnsolved;

@end
