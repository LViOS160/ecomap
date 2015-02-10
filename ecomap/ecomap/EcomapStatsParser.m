//
//  EcomapStatsParser.m
//  ecomap
//
//  Created by ohuratc on 09.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapStatsParser.h"
#import "EcomapPathDefine.h"

@implementation EcomapStatsParser

+ (id)valueForKey:(NSString *)key inGeneralStatsArray:(NSArray *)generalStats
{
    for(id stats in generalStats) {
        if([stats isKindOfClass:[NSArray class]]) {
            if([[(NSArray *)stats firstObject] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *stat = (NSDictionary *)[(NSArray *)stats firstObject];
                if([stat valueForKey:key]) {
                    return [stat valueForKey:key];
                } else {
                    continue;
                }
            }
        }
    }
    
    return nil;
}

@end
