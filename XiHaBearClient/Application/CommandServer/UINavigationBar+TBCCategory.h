//
//  UINavigationBar+TBCCategory.h
//  TBClient
//
//  Created by douj on 13-3-18.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UINavigationBar (TBCCategory)
-(void)setBackgroundImage:(NSString*)imageName;

/**
 by:高海军
 */

-(void)addSubviewOnBar:(UIView *)view;
-(void)removeSubview:(UIView *)view;


@end
