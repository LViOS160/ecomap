//
//  EcomapCoreDataControlPanel.h
//  ecomap
//
//  Created by Admin on 19.10.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Problem.h"
#import "EcomapProblemDetails.h"

@interface EcomapCoreDataControlPanel : NSObject

+(instancetype)sharedInstance;

-(void)addProblemIntoCoreData;
-(void)loadData;
-(Problem*)returnDetail:(NSInteger)id1;

@property (nonatomic, strong) NSArray *allProblems;
@property (nonatomic, strong) NSArray *descr;

@end
