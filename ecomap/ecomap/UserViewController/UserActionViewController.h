//
//  UserActionViewController.h
//  ecomap
//
//  Created by Vasilii Kotsiuba on 2/23/15.
//  Copyright (c) 2015 SoftServe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserActionViewController : UIViewController
//What shoul be done after userAction (login, logout) ends
@property (nonatomic, copy) void (^dismissBlock)(void);
@end
