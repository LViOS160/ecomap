//
//  ProfileViewController.h
//  ecomap
//
//  Created by Vasilii Kotsiuba on 2/23/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"

@interface ProfileViewController : UIViewController <UserAction>

@property (nonatomic, copy) void (^dismissBlock)(void);

@end
