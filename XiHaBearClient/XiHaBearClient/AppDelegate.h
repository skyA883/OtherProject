//
//  AppDelegate.h
//  XiHaBearClient
//
//  Created by liuxuan on 15-4-29.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHTabBarController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *loginRoot;
@property (strong, nonatomic) XHTabBarController *tabBarController;



/**
 * 改变rootViewController
 * isHome --- YES：homeViewController NO：LoginViewController
 */
- (void)changeRootViewController:(BOOL) isHome;


/**
 *设置tabItem bradge
 *viewIndex item idenx
 *txt bradge
 */
- (void)setTabBarItemBadge:(int)viewIndex badge:(NSString *)txt;

@end

