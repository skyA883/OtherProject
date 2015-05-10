//
//  XHHomeViewController.m
//  XiHaBearClient
//
//  Created by letv_lzb on 15/5/2.
//  Copyright (c) 2015年 XiHaBear. All rights reserved.
//

#import "XHHomeViewController.h"
#import "HomeModel.h"

@interface XHHomeViewController ()

@property (nonatomic, strong)HomeModel *dataModel;

@end

@implementation XHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataModel = [[HomeModel alloc] initWithBlock:^(BOOL isSuccess) {
        
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.dataModel getHomeData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
