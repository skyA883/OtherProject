//
//  AppDelegate.m
//  XiHaBearClient
//
//  Created by liuxuan on 15-4-29.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "AppDelegate.h"
#import "XHTabBarController.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7.0)
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    [self changeRootViewController:YES];
    /*
    [[IFAppSetting shareAppSetting] settingLaunchingWithOptions:launchOptions];
    
    [[IFAppSetting shareAppSetting] settingNetworkState];
     */
//    [self dataInit];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}



- (void)changeRootViewController:(BOOL) isHome
{
    if (isHome)
    {
        if (self.loginRoot)
        {
            [self.loginRoot.view removeFromSuperview];
            _loginRoot = nil;
        }
        
        if (nil == self.tabBarController)
        {
            self.tabBarController = [[XHTabBarController alloc] init];
        }
        self.window.rootViewController = self.tabBarController;
        
        
    }else
    {
        /*
        if (self.tabBarController)
        {
            [self.tabBarController.view removeFromSuperview];
            self.tabBarController = nil;
        }
        IFLoginViewController *loginView = [[[IFLoginViewController alloc] init] autorelease];
        self.loginRoot = [[[IFBaseNavigatonController alloc] initWithRootViewController:loginView] autorelease];
        self.loginRoot.navigationItem.backBarButtonItem = nil;
        self.window.rootViewController = self.loginRoot;
         */
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)setTabBarItemBadge:(int)viewIndex badge:(NSString *)txt
{
    if (_tabBarController && viewIndex<_tabBarController.viewControllers.count)
    {
        UITabBarItem* item =  [_tabBarController.tabBar.items objectAtIndex:viewIndex];
        item.badgeValue = txt;
    }
}


@end
