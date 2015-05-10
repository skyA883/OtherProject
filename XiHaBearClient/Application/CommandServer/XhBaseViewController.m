//
//  XhBaseViewController.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/1.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XhBaseViewController.h"


#import "TBCSliderReturnController.h"

@interface XhBaseViewController ()
@property (nonatomic, strong) TBCSliderReturnController *sliderReturnController;
@end


@implementation XhBaseViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rect = self.view.frame;
    rect.size.height = kDefaultScreenheight;
    self.view.frame = rect;
    self.view.backgroundColor = [NSString colorWithHexString:@"#f7f9fa"];
    //    [self.view setGradientBackgroundWithStartColor:[NSString colorWithHexString:@"#f7f9fa"] endColor:[NSString colorWithHexString:@"#f7f9fa"]];
    // Do any additional setup after loading the view.
    //前一个viewcontroller
    if (self.navigationController.viewControllers.count > 1)
    {
        self.sliderReturnController = [[TBCSliderReturnController alloc] init] ;
        [self.sliderReturnController  addCleanSelector:@selector(cleanBeforeReturn) target:self];
        UIViewController* controllerBackGround = [self.navigationController.viewControllers safeObjectAtIndex:self.navigationController.viewControllers.count-2];
        self.sliderReturnController.navigationBar = self.navigationController.navigationBar;
        [self.sliderReturnController screenShotTop];
        self.sliderReturnController.viewInBackGround = controllerBackGround.view;
        int64_t delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.sliderReturnController startLastViewScreenShot];
        });
        [self.sliderReturnController addPanGestureTo:self.view andNavigationController:self.navigationController];
    }
}

//子类重写 在滑动返回时清理资源
-(void)cleanBeforeReturn
{
    
}
- (void)dealloc
{
    self.sliderReturnController = nil;
}


@end
