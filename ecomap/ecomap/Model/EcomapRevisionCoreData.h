//
//  EcomapRevisionCoreData.h
//  ecomap
//
//  Created by Pavlo Dumyak on 10/20/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EcomapRevisionCoreData : NSObject

+ (instancetype)sharedInstance;
- (void)loadDifferance;
- (void)checkRevison;


@property (nonatomic, strong) NSArray *allRevisions;

@end
