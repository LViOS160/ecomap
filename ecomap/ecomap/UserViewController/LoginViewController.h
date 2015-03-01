//
//  LoginViewController.h
//  ecomap
//
//  Created by Anton Kovernik on 02.02.15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import "UserActivityViewController.h"

@protocol UserAction <NSObject>
//What shoul be done after user action (login, logout) ends success
@property (nonatomic, copy) void (^dismissBlock)(void);

@end

@interface LoginViewController : UserActivityViewController <UserAction>

@property (nonatomic, copy) void (^dismissBlock)(void);

@end


