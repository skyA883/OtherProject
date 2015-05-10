//
//  UIViewController+TBCCategory.h
//  TBClient
//
//  Created by douj on 13-3-20.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (TBCCategory)

-(void)setLeftBarItem:(UIView*) view;
-(void)setRightBarItem:(UIView*) view;
-(void)setTitleView:(UIView*)view;
- (void)setTitleLable:(NSString *)title;
-(void)setBackButton;

@end
