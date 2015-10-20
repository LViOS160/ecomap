//
//  EcomapRevisionCoreData.m
//  ecomap
//
//  Created by Pavlo Dumyak on 10/20/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "EcomapRevisionCoreData.h"
#import "EcomapFetcher.h"
@implementation EcomapRevisionCoreData

+ (instancetype)sharedInstance
{
    static EcomapRevisionCoreData *object;
    static dispatch_once_t predicat;
    dispatch_once(&predicat, ^{object = [[EcomapRevisionCoreData alloc] init];});
    return object;
}


- (void)checkRevison
{
    [EcomapFetcher checkRevision:^(BOOL differance, NSError *error) {
    if (!error)
        {
            if(differance)
            {
                [EcomapFetcher loadProblemsDifferance:^(NSArray *problems, NSError *error) {
                    self.allRevisions = [NSArray arrayWithArray:problems];
                    if (!error)
                    {
                        //self.descr = [NSArray arrayWithArray:problems];
                        //[self addProblemIntoCoreData];
                    }
                }];
            }
          
        }
    }];
}


- (void)loadDifferance
{
    
    
    
    
    
}


@end
