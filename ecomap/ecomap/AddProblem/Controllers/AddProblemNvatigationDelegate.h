//
//  AddProblemNvatigationDelegate.h
//  ecomap
//
//  Created by Anton Kovernik on 11.03.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AddProblemNvatigationDelegate <NSObject>

@required

- (void)nextPage;
- (void)prevPage;

@end
