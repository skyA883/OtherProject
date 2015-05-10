//
//  XHBearViewController.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/1.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHBearViewController.h"
#import "XHBearBLEManagerVC.h"
@interface XHBearViewController ()

@end


@implementation XHBearViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton * tempBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [tempBtn setTitle:@"进入蓝牙管理页面" forState:UIControlStateNormal];
    tempBtn.frame = CGRectMake(0, 0, 200, 44);
    tempBtn.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
    [tempBtn addTarget:self action:@selector(doButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tempBtn];
}

-(void)doButton:(UIButton*)button
{
    XHBearBLEManagerVC * vc = [[XHBearBLEManagerVC alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}
@end
