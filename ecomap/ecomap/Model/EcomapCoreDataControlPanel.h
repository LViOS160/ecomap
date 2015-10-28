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
#import "MapViewController.h"
#import "Resource.h"
#import "Comment.h"


@class MapViewController;

@interface EcomapCoreDataControlPanel : NSObject

+ (instancetype) sharedInstance;

- (void) addProblemIntoCoreData;
- (void) loadData;
- (Problem*) returnDetail:(NSInteger)identifier;



@property (nonatomic, strong) NSArray *allProblems;
@property (nonatomic, strong) NSArray *descr;

@property (nonatomic, strong) MapViewController *map;

@property (nonatomic, strong) NSArray *resourcesFromWeb;
@property (nonatomic, strong) NSString *resourceContent;

@property (nonatomic, strong) NSArray *commentsFromWeb;

- (void) addCommentsIntoCoreData;
- (void) requestForAllComments;

- (void) addResourceIntoCD;
- (void) loadResources;

@end
