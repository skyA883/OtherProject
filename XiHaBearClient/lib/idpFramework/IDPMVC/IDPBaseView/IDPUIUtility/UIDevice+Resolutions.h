//
//  UIDevice+Resolutions.h
//  TBClient
//
//  Created by TB.Gao on 12-12-12.
//
//

#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>

enum {
	UIDeviceResolution_Unknown			= 0,
    UIDeviceResolution_iPhoneStandard	= 1,    // iPhone 1,3,3GS 标准	(320x480px)
    UIDeviceResolution_iPhoneRetina35	= 2,    // iPhone 4,4S 高清 3.5"	(640x960px)
    UIDeviceResolution_iPhoneRetina4	= 3,    // iPhone 5 高清 4"		(640x1136px)
    UIDeviceResolution_iPadStandard		= 4,    // iPad 1,2 标准		(1024x768px)
    UIDeviceResolution_iPadRetina		= 5     // iPad 3 高清			(2048x1536px)
}; typedef NSUInteger UIDeviceResolution;

@interface UIDevice (Resolutions)

- (UIDeviceResolution)resolution;

NSString *NSStringFromResolution(UIDeviceResolution resolution);

@end
