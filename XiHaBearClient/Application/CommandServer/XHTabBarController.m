//
//  XHTabBarController.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/1.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHTabBarController.h"
#import "XhBaseNavigationController.h"
#import "XHHomeViewController.h"
#import "XHPlayViewController.h"
#import "SettingViewController.h"
#import "XHBearViewController.h"


#define kTbcTabbarBackground  @"menu_bg"
#define kTbcTabbarHeight      50.0f


@interface XHTabBarController ()

@end

@implementation XHTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    //更换背景
    //ios5 直接跟换背景
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 5.0)
    {
        [self.tabBar setBackgroundImage:[UIImage imageNamed:kTbcTabbarBackground]];
    }
    else
    {
        CGRect frame = CGRectMake(0,0,self.view.bounds.size.width,kTbcTabbarHeight);
        UIView *view = [[UIView alloc] initWithFrame:frame];
        UIImage *tabImage = [UIImage imageNamed:kTbcTabbarBackground];
        UIColor *color = [[UIColor alloc] initWithPatternImage:tabImage];
        [view setBackgroundColor:color];
        [[self tabBar] insertSubview:view atIndex:0];
        
    }
    
    CGFloat screenHeight = 568;
    
    //调整高度
    if ([[UIDevice currentDevice] resolution] == UIDeviceResolution_iPhoneRetina4)
    {
        if([[UIDevice currentDevice] systemVersion].floatValue >= 7.0)
        {
            screenHeight = 589;
        }
        else
        {
            screenHeight = 569;
        }
        self.tabBar.frame = CGRectMake(0, screenHeight-kTbcTabbarHeight - 20, 320, kTbcTabbarHeight);
        UIView * transitionView = [[self.view subviews] objectAtIndex:0];
        transitionView.height = screenHeight-kTbcTabbarHeight - 20;
    }
    else
    {
        if([[UIDevice currentDevice] systemVersion].floatValue >= 7.0)
        {
            screenHeight = 501;
        }
        else
        {
            screenHeight = 480;
        }
        self.tabBar.frame = CGRectMake(0, screenHeight-kTbcTabbarHeight - 20
                                       
                                       , 320, kTbcTabbarHeight);
        UIView * transitionView = [[self.view subviews] objectAtIndex:0];
        transitionView.height = screenHeight-kTbcTabbarHeight - 20;
    }
    
    //放界面
    //大厅
    XHHomeViewController *homeViewController = [[XHHomeViewController alloc] init];
    homeViewController.view.backgroundColor = [UIColor redColor];
    XhBaseNavigationController*homeNavi  = [[XhBaseNavigationController alloc] initWithRootViewController:homeViewController];
    
    // 自动播放
    XHPlayViewController *msgViewController = [[XHPlayViewController alloc] init];
    XhBaseNavigationController*msgNavi  = [[XhBaseNavigationController alloc] initWithRootViewController:msgViewController];
    
    // 玩具
    XHBearViewController *moreViewController = [[XHBearViewController alloc] init];
    
    XhBaseNavigationController*moreNavi  = [[XhBaseNavigationController alloc] initWithRootViewController:moreViewController] ;
    
    NSArray* tabBarViewArray = [[NSArray alloc] initWithObjects: homeNavi, msgNavi,moreNavi, nil];
    self.viewControllers = tabBarViewArray;
    //    self.selectedIndex = TB_TAB_INDEX_HOMEPAGE;
    
    UITabBarItem* tabBarItem0 =[self.tabBar.items objectAtIndex:0];
    UITabBarItem* tabBarItem1 =[self.tabBar.items objectAtIndex:1];
    UITabBarItem* tabBarItem2 =[self.tabBar.items objectAtIndex:2];
    UIImage *image0 = [UIImage imageNamed:@"ico_home_page_n"];
    UIImage *image0s = [UIImage imageNamed:@"ico_home_page_s"];
    UIImage *image1 = [UIImage imageNamed:@"ico_msg_page_n"];
    UIImage *image1s = [UIImage imageNamed:@"ico_msg_page_s"];
    UIImage *image2 = [UIImage imageNamed:@"ico_more_page_n"];
    UIImage *image2s = [UIImage imageNamed:@"ico_more_page_s"];
    tabBarItem0.imageInsets = UIEdgeInsetsMake(0,0,-0,0);
    [tabBarItem0 setTitle:@"首页"];
    tabBarItem1.imageInsets = UIEdgeInsetsMake(4,0,-0,0);
    [tabBarItem1 setTitle:@"自动播放"];
    tabBarItem2.imageInsets = UIEdgeInsetsMake(4,0,-0,0);
    [tabBarItem2 setTitle:@"玩具"];
    
    
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 5.0)
    {
        NSDictionary* textAttributesSelected = [NSDictionary dictionaryWithObject:[UIColor colorWithRGBHex:0xFF939393] forKey:NSForegroundColorAttributeName];
        
        NSDictionary* textAttributesNormal = [NSDictionary dictionaryWithObject:[UIColor colorWithRGBHex:0xFFffffff] forKey:NSForegroundColorAttributeName];
        
        if ([[UIDevice currentDevice] systemVersion].floatValue > 7.0) {
            [tabBarItem0 setImage:[image0 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            
            [tabBarItem0 setSelectedImage:[image0s imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }else{
            [tabBarItem0 setFinishedSelectedImage:image0s withFinishedUnselectedImage:image0];
        }
        [tabBarItem0 setTitleTextAttributes:textAttributesSelected forState:UIControlStateSelected];
        [tabBarItem0 setTitleTextAttributes:textAttributesNormal forState:UIControlStateNormal];
        
        if ([[UIDevice currentDevice] systemVersion].floatValue > 7.0) {
            [tabBarItem1 setImage:[image1 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            
            [tabBarItem1 setSelectedImage:[image1s imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }else{
            [tabBarItem1 setFinishedSelectedImage:image1s withFinishedUnselectedImage:image1];
        }

        [tabBarItem1 setTitleTextAttributes:textAttributesSelected forState:UIControlStateSelected];
        [tabBarItem1 setTitleTextAttributes:textAttributesNormal forState:UIControlStateNormal];
        if ([[UIDevice currentDevice] systemVersion].floatValue > 7.0) {
            [tabBarItem2 setImage:[image2 imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            
            [tabBarItem2 setSelectedImage:[image2s imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }else{
            [tabBarItem2 setFinishedSelectedImage:image2s withFinishedUnselectedImage:image2];
        }
        [tabBarItem2 setTitleTextAttributes:textAttributesSelected forState:UIControlStateSelected];
        [tabBarItem2 setTitleTextAttributes:textAttributesNormal forState:UIControlStateNormal];
        //        [tabBarItem3 setFinishedSelectedImage:image3s withFinishedUnselectedImage:image3];
        //        [tabBarItem3 setTitleTextAttributes:textAttributesSelected forState:UIControlStateSelected];
        //        [tabBarItem3 setTitleTextAttributes:textAttributesNormal forState:UIControlStateNormal];
        
    }
    else
    {
        tabBarItem0.image = image0;
        tabBarItem1.image = image1;
        tabBarItem2.image = image2;
        //        tabBarItem3.image = image3;
        
    }
}



- (BOOL)wantsFullScreenLayout
{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
