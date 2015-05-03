//
//  UIViewController+TBCCategory.m
//  TBClient
//
//  Created by douj on 13-3-20.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "UIViewController+TBCCategory.h"

@implementation UIViewController (TBCCategory)

-(void)setLeftBarItem:(UIView*) view
{
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = left;
}

-(void)setRightBarItem:(UIView*) view
{
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.rightBarButtonItem = right;
}

-(void)setTitleView:(UIView*)view
{
    self.navigationItem.titleView = view;
}


- (void)setTitleLable:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.text = title;
    [self setTitleView:titleLabel];
}


-(void)setBackButton
{
    UIImage* buttImg = [UIImage imageNamed:@"navi_back_icon.png"];
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0.0f,(44.0-buttImg.size.height)/2, buttImg.size.width, buttImg.size.height);
    [backButton addTarget:self action:@selector(popNavigationControllerWithAnimate) forControlEvents:UIControlEventTouchUpInside];
	[backButton setImage:buttImg forState:UIControlStateNormal];
//    UIImage *returnHighlightedImage = [UIImage imageNamed:@"but_s.png"];
//    [backButton setBackgroundImage:returnHighlightedImage forState:UIControlStateHighlighted];
    
    [self setLeftBarItem:backButton];
}

- (void)popNavigationControllerWithAnimate
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
