//
//  UINavigationBar+TBCCategory.m
//  TBClient
//
//  Created by douj on 13-3-18.
//  Copyright (c) 2013年 baidu. All rights reserved.
//

#import "UINavigationBar+TBCCategory.h"

#define kDefaultBarFrame			CGRectMake(0, 0, 320, 44)
#define kNaviBarFrame               CGRectMake(0, 0, 320, 44)

#define kIntZero					0
#define kFloatZero					0.0
#define kStatusBarheight			20
#define kDefaultBarheight			44
#define kSystemAnimationDuration	0.3

#define kDefaultBackgroundImageFile         @"navigation_bg.png"
#define kDefaultBackgroundImageFileIOS7		@"navigation_bg_ios7.png"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UINavigationBar (TBCCategory)
+(void)initialize
{
    if ([[[UIDevice currentDevice] systemVersion] intValue]>=7.0) {
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:kDefaultBackgroundImageFileIOS7] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:[NSString colorWithHexString:@"#3ca7e4"]];
    }
    else if ([[[UIDevice currentDevice] systemVersion] intValue]>=5.0) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:kDefaultBackgroundImageFile] forBarMetrics:UIBarMetricsDefault];
	}else {
         [[UINavigationBar appearance] insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:kDefaultBackgroundImageFile]] atIndex:0];
    }
}


- (void)drawRect:(CGRect)rect
{
	if ([[[UIDevice currentDevice] systemVersion] intValue] < 5.0) {
        UIImage *backgroundImage = [UIImage imageNamed:kDefaultBackgroundImageFile];
        [backgroundImage drawInRect:CGRectMake(kIntZero, kIntZero, self.frame.size.width, self.frame.size.height)];
    }
}

-(void)setBackgroundImage:(NSString*)imageName{
	static UIView* cnb_backgroundView = nil;
    static UIImage* cnb_image = nil;
    if(imageName == nil){
		[cnb_backgroundView removeFromSuperview];
	}
	else{
		cnb_image=[UIImage imageNamed:imageName];
		cnb_backgroundView = [[UIImageView alloc] initWithImage:cnb_image];
		cnb_backgroundView.frame = CGRectMake(0.f, 0.f, self.frame.size.width, self.frame.size.height);
		cnb_backgroundView.autoresizingMask  = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:cnb_backgroundView];
		[self sendSubviewToBack:cnb_backgroundView];
	}
}

-(void)addSubviewOnBar:(UIView *)view
{
    //[self addSubview:view];
    [self insertSubview:view atIndex:self.subviews.count - 2];
    //[self sendSubviewToBack:view];
}

-(void)removeSubview:(UIView *)view
{
    [view removeFromSuperview];
}

@end
