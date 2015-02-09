//
//  EcomapStatsParser.h
//  ecomap
//
//  Created by ohuratc on 09.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EcomapStatsParser : NSObject

+ (id)valueForKey:(NSString *)key inGeneralStatsArray:(NSArray *)generalStats;

@end
