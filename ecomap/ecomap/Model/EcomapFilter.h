//
//  EcomapFilter.h
//  ecomap
//
//  Created by ohuratc on 19.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EcomapProblemFilteringMask.h"

@interface EcomapFilter : NSObject

+ (NSArray *)filterProblemsArray:(NSArray *)problems usingFilteringMask:(EcomapProblemFilteringMask *)mask;

@end
